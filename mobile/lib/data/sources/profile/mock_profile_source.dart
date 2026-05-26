import 'dart:async';

import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/sources/profile/profile_source.dart';

class MockProfileSource implements ProfileSource {
  MockProfileSource();

  final StreamController<Profile?> _controller =
      StreamController<Profile?>.broadcast();

  Profile _current = Profile(
    id: 'mock-user-1',
    email: 'demo@health.app',
    username: 'demo_athlete',
    displayName: 'Demo Athlete',
    gender: Gender.other,
    dateOfBirth: DateTime(1998, 6, 15),
    heightCm: 180,
    weightKg: 72,
    activityLevel: ActivityLevel.moderate,
    targetWeightKg: 70,
    onboardedAt: DateTime.now().subtract(const Duration(days: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  @override
  Future<Profile?> getCurrent() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _current;
  }

  @override
  Stream<Profile?> watchCurrent() async* {
    yield _current;
    yield* _controller.stream;
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
    bool markOnboarded = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _current = _current.copyWith(
      username: username,
      displayName: displayName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      targetWeightKg: targetWeightKg,
      onboardedAt: markOnboarded ? DateTime.now() : _current.onboardedAt,
      updatedAt: DateTime.now(),
    );
    _controller.add(_current);
    return _current;
  }
}
