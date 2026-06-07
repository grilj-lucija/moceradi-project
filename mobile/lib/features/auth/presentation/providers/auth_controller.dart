import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/app_user.dart';
import 'package:health_app/di/providers.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password);
    return result.fold(
      ok: (_) {
        state = const AsyncData(null);
        return null;
      },
      err: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
    );
  }

  Future<Failure?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        );
    return result.fold(
      ok: (_) {
        state = const AsyncData(null);
        return null;
      },
      err: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
