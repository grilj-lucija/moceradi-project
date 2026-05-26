import 'dart:async';
import 'dart:typed_data';

import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/sources/profile/profile_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameTakenException implements Exception {
  const UsernameTakenException(this.username);
  final String username;

  @override
  String toString() => 'UsernameTakenException($username)';
}

class SupabaseProfileSource implements ProfileSource {
  SupabaseProfileSource(this._client);

  final SupabaseClient _client;

  static const _table = 'profiles';
  static const _avatarBucket = 'avatars';

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Profile?> getCurrent() async {
    final uid = _uid;
    if (uid == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('id', uid)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  @override
  Stream<Profile?> watchCurrent() async* {
    yield await getCurrent();
    final uid = _uid;
    if (uid == null) return;

    final stream = _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', uid);

    await for (final rows in stream) {
      if (rows.isEmpty) {
        yield null;
      } else {
        yield Profile.fromJson(rows.first);
      }
    }
  }

  @override
  Future<Profile> upsert({
    String? username,
    String? displayName,
    Gender? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    double? targetWeightKg,
    String? avatarUrl,
    bool markOnboarded = false,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthException('Not signed in');
    }

    final payload = <String, dynamic>{
      'id': uid,
      'username': ?username,
      'display_name': ?displayName,
      'gender': ?gender?.wireValue,
      'date_of_birth': ?dateOfBirth?.toIso8601String().split('T').first,
      'height_cm': ?heightCm,
      'weight_kg': ?weightKg,
      'activity_level': ?activityLevel?.wireValue,
      'target_weight_kg': ?targetWeightKg,
      'avatar_url': ?avatarUrl,
      if (markOnboarded) 'onboarded_at': DateTime.now().toIso8601String(),
    };

    try {
      final row = await _client
          .from(_table)
          .upsert(payload)
          .select()
          .single();
      return Profile.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505' && e.message.toLowerCase().contains('username')) {
        throw UsernameTakenException(username ?? '');
      }
      rethrow;
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final result = await _client.rpc<bool>(
      'is_username_available',
      params: {'p_username': username},
    );
    return result;
  }

  @override
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthException('Not signed in');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$uid/avatar_$timestamp.$fileExtension';

    await _client.storage.from(_avatarBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
            cacheControl: '3600',
          ),
        );

    return _client.storage.from(_avatarBucket).getPublicUrl(path);
  }
}
