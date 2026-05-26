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
    bool markOnboarded = false,
  });
}
