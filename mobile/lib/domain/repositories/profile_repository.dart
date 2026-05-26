import 'dart:typed_data';

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
    String? avatarUrl,
    bool markOnboarded = false,
  });

  Future<Result<bool>> isUsernameAvailable(String username);

  Future<Result<String>> uploadAvatar({
    required Uint8List bytes,
    required String contentType,
    required String fileExtension,
  });
}
