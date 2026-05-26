import 'dart:async';

import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/data/sources/user_goals/user_goals_source.dart';

class MockUserGoalsSource implements UserGoalsSource {
  MockUserGoalsSource();

  final StreamController<UserGoals?> _controller =
      StreamController<UserGoals?>.broadcast();

  UserGoals _current = UserGoals(
    userId: 'mock-user-1',
    intents: const [GoalType.buildEndurance, GoalType.improveGeneralFitness],
    activityMetric: ActivityMetric.runningDistance,
    activityTarget: 25,
    pace: GoalPace.balanced,
    updatedAt: DateTime.now(),
  );

  @override
  Future<UserGoals?> getCurrent() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _current;
  }

  @override
  Stream<UserGoals?> watchCurrent() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<UserGoals> upsert({
    List<GoalType>? intents,
    ActivityMetric? activityMetric,
    double? activityTarget,
    GoalPace? pace,
    bool? kcalOverride,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _current = _current.copyWith(
      intents: intents,
      activityMetric: activityMetric,
      activityTarget: activityTarget,
      pace: pace,
      kcalOverride: kcalOverride,
      updatedAt: DateTime.now(),
    );
    _controller.add(_current);
    return _current;
  }
}
