import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/user_goals.dart';

abstract interface class UserGoalsRepository {
  Future<Result<UserGoals?>> getCurrent();

  Stream<UserGoals?> watchCurrent();

  Future<Result<UserGoals>> upsert({
    List<GoalType>? intents,
    ActivityMetric? activityMetric,
    double? activityTarget,
    GoalPace? pace,
    bool? kcalOverride,
  });
}
