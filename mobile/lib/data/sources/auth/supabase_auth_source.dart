import 'package:health_app/data/models/app_user.dart';
import 'package:health_app/data/sources/auth/auth_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailConfirmationPendingException implements Exception {
  const EmailConfirmationPendingException(this.email);
  final String email;

  @override
  String toString() => 'EmailConfirmationPendingException($email)';
}

class SupabaseAuthSource implements AuthSource {
  SupabaseAuthSource(this._client);

  final SupabaseClient _client;

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _client.auth.onAuthStateChange.map(
      (state) => _mapUser(state.session?.user),
    );
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = _mapUser(response.user);
    if (user == null) {
      throw const AuthException('Sign-in returned no user');
    }
    return user;
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName == null ? null : {'display_name': displayName},
    );
    final user = _mapUser(response.user);
    if (user == null) {
      throw const AuthException('Sign-up returned no user');
    }
    if (response.session == null) {
      throw EmailConfirmationPendingException(email);
    }
    return user;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
