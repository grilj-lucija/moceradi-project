import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/app_user.dart';
import 'package:health_app/data/sources/auth/auth_source.dart';
import 'package:health_app/data/sources/auth/supabase_auth_source.dart';
import 'package:health_app/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._source);

  final AuthSource _source;

  @override
  AppUser? get currentUser => _source.currentUser;

  @override
  Stream<AppUser?> watchCurrentUser() => _source.watchCurrentUser();

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _source.signInWithEmail(
        email: email,
        password: password,
      );
      return Result.ok(user);
    } on Object catch (e) {
      return Result.err(AuthFailure(_friendlyMessage(e), e));
    }
  }

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _source.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Result.ok(user);
    } on EmailConfirmationPendingException catch (e) {
      return Result.err(EmailConfirmationPendingFailure(e.email));
    } on Object catch (e) {
      return Result.err(AuthFailure(_friendlyMessage(e), e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _source.signOut();
      return const Result.ok(null);
    } on Object catch (e) {
      return Result.err(AuthFailure(_friendlyMessage(e), e));
    }
  }
}

String _friendlyMessage(Object error) {
  if (error is AuthApiException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Invalid email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists.';
      case 'weak_password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Too many attempts. Please try again in a moment.';
      case 'validation_failed':
        return 'Please check your email and password.';
    }
    if (error.statusCode == '400' || error.statusCode == '422') {
      return 'Invalid email or password.';
    }
    return 'Could not sign you in. Please try again.';
  }
  if (error is AuthException) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}
