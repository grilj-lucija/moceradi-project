import 'package:health_app/data/models/user_goals.dart';

abstract interface class UserGoalsSource {
  Future<UserGoals?> getCurrent();

  Stream<UserGoals?> watchCurrent();

  Future<UserGoals> upsert({
    List<GoalType>? intents,
    ActivityMetric? activityMetric,
    double? activityTarget,
    GoalPace? pace,
    bool? kcalOverride,
  });
}
