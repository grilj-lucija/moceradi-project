import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/dashboard/services/activity_progress.dart';

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}

final recentActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  final result = await repo.listRecent();
  return result.fold(
    ok: (items) => items,
    err: (failure) => throw _FailureException(failure),
  );
});

final weeklyActivityProgressProvider =
    Provider<WeeklyActivityProgress?>((ref) {
  final goals = ref.watch(currentUserGoalsProvider).value;
  final metric = goals?.activityMetric;
  final target = goals?.activityTarget;
  if (metric == null || target == null || target <= 0) return null;

  final activities = ref.watch(recentActivitiesProvider).value ?? const [];
  final now = DateTime.now();
  final weekStart = ActivityProgress.startOfWeek(now);
  final weekActivities = ActivityProgress.filterSince(activities, weekStart);
  final value = ActivityProgress.metricValue(metric, weekActivities);
  return WeeklyActivityProgress(
    metric: metric,
    value: value,
    target: target,
    weekStart: weekStart,
  );
});

final todayActivityStatsProvider = Provider<TodayActivityStats>((ref) {
  final activities = ref.watch(recentActivitiesProvider).value ?? const [];
  return ActivityProgress.todayStats(activities, DateTime.now());
});
