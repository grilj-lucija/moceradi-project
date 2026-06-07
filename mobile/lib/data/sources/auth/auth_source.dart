import 'package:health_app/data/models/app_user.dart';

abstract interface class AuthSource {
  Stream<AppUser?> watchCurrentUser();

  AppUser? get currentUser;

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}
