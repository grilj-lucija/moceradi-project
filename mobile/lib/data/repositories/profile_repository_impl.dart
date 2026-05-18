import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/sources/profile/profile_source.dart';
import 'package:health_app/data/sources/profile/supabase_profile_source.dart';
import 'package:health_app/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._source);

  final ProfileSource _source;

  @override
  Future<Result<Profile?>> getCurrent() async {
    try {
      final profile = await _source.getCurrent();
      return Result.ok(profile);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Stream<Profile?> watchCurrent() => _source.watchCurrent();

  @override
  Future<Result<Profile>> upsert({
    String? username,
    String? displayName,
    Gender? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    bool markOnboarded = false,
  }) async {
    try {
      final profile = await _source.upsert(
        username: username,
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
        weightKg: weightKg,
        markOnboarded: markOnboarded,
      );
      return Result.ok(profile);
    } on UsernameTakenException {
      return const Result.err(
        ValidationFailure('Username already taken'),
      );
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }
}
