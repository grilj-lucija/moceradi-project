import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/data/sources/user_goals/user_goals_source.dart';
import 'package:health_app/domain/repositories/user_goals_repository.dart';

class UserGoalsRepositoryImpl implements UserGoalsRepository {
  UserGoalsRepositoryImpl(this._source);

  final UserGoalsSource _source;

  @override
  Future<Result<UserGoals?>> getCurrent() async {
    try {
      return Result.ok(await _source.getCurrent());
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Stream<UserGoals?> watchCurrent() => _source.watchCurrent();

  @override
  Future<Result<UserGoals>> upsert({
    List<GoalType>? intents,
    ActivityMetric? activityMetric,
    double? activityTarget,
    GoalPace? pace,
    bool? kcalOverride,
  }) async {
    try {
      final goals = await _source.upsert(
        intents: intents,
        activityMetric: activityMetric,
        activityTarget: activityTarget,
        pace: pace,
        kcalOverride: kcalOverride,
      );
      return Result.ok(goals);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }
}
