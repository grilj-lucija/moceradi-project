import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile?>> getCurrent();

  Stream<Profile?> watchCurrent();

  Future<Result<Profile>> upsert({
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
