import 'dart:typed_data';

import 'package:health_app/data/models/profile.dart';

abstract interface class ProfileSource {
  Future<Profile?> getCurrent();

  Stream<Profile?> watchCurrent();

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
  });

  Future<bool> isUsernameAvailable(String username);

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  });
}
