import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> watchCurrentUser();

  AppUser? get currentUser;

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<void>> signOut();
}
