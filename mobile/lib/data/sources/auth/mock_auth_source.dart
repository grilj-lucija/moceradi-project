import 'dart:async';

import 'package:health_app/data/models/app_user.dart';
import 'package:health_app/data/sources/auth/auth_source.dart';

class MockAuthSource implements AuthSource {
  MockAuthSource();

  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _current;

  static const _validEmail = 'demo@health.app';
  static const _validPassword = 'demo1234';

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (email != _validEmail || password != _validPassword) {
      throw StateError('Invalid credentials. Use $_validEmail / $_validPassword');
    }
    _current = const AppUser(
      id: 'mock-user-1',
      email: _validEmail,
      displayName: 'Demo Athlete',
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _current = AppUser(
      id: 'mock-${email.hashCode}',
      email: email,
      displayName: displayName,
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _current = null;
    _controller.add(null);
  }
}
