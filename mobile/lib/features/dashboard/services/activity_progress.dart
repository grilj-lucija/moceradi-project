import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/models/user_goals.dart';

class WeeklyActivityProgress extends Equatable {
  const WeeklyActivityProgress({
    required this.metric,
    required this.value,
    required this.target,
    required this.weekStart,
  });

  final ActivityMetric metric;
  final double value;
  final double target;
  final DateTime weekStart;

  double get fraction {
    if (target <= 0) return 0;
    return (value / target).clamp(0.0, 1.0);
  }

  double get remaining => (target - value).clamp(0.0, double.infinity);

  bool get isComplete => target > 0 && value >= target;

  @override
  List<Object?> get props => [metric, value, target, weekStart];
}

class TodayActivityStats extends Equatable {
  const TodayActivityStats({
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.distanceKm,
    required this.workouts,
  });

  static const TodayActivityStats zero = TodayActivityStats(
    caloriesBurned: 0,
    activeMinutes: 0,
    distanceKm: 0,
    workouts: 0,
  );

  final double caloriesBurned;
  final int activeMinutes;
  final double distanceKm;
  final int workouts;

  @override
  List<Object?> get props =>
      [caloriesBurned, activeMinutes, distanceKm, workouts];
}

class ActivityProgress {
  const ActivityProgress._();

  static DateTime startOfWeek(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: now.weekday - 1));
  }

  static DateTime startOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day);

  static List<Activity> filterSince(List<Activity> all, DateTime since) {
    return all.where((a) => !a.startedAt.isBefore(since)).toList();
  }

  static double _singleActivityMetric(ActivityMetric metric, Activity a) {
    switch (metric) {
      case ActivityMetric.cyclingDistance:
        return a.type == ActivityType.cycling ? a.distanceMeters / 1000 : 0;
      case ActivityMetric.runningDistance:
        return a.type == ActivityType.running ? a.distanceMeters / 1000 : 0;
      case ActivityMetric.walkingDistance:
        return a.type == ActivityType.walking ? a.distanceMeters / 1000 : 0;
      case ActivityMetric.activeMinutes:
        return a.durationSeconds / 60;
      case ActivityMetric.caloriesBurned:
        return a.caloriesKcal ?? 0;
      case ActivityMetric.workouts:
        return 1;
    }
  }

  static double metricValue(
    ActivityMetric metric,
    List<Activity> activities,
  ) {
    return activities.fold<double>(
      0,
      (s, a) => s + _singleActivityMetric(metric, a),
    );
  }

  static List<double> metricValuePerDay(
    ActivityMetric metric,
    List<Activity> all,
    DateTime weekStart,
  ) {
    final values = List<double>.filled(7, 0);
    for (final a in all) {
      final local = a.startedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final diff = day.difference(weekStart).inDays;
      if (diff < 0 || diff > 6) continue;
      values[diff] += _singleActivityMetric(metric, a);
    }
    return values;
  }

  static int currentDailyStreak(List<Activity> all, DateTime now) {
    if (all.isEmpty) return 0;
    final days = <DateTime>{};
    for (final a in all) {
      final local = a.startedAt.toLocal();
      days.add(DateTime(local.year, local.month, local.day));
    }
    var anchor = startOfDay(now);
    if (!days.contains(anchor)) {
      anchor = anchor.subtract(const Duration(days: 1));
      if (!days.contains(anchor)) return 0;
    }
    var streak = 0;
    var cursor = anchor;
    while (days.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static TodayActivityStats todayStats(List<Activity> all, DateTime now) {
    final today = filterSince(all, startOfDay(now));
    return TodayActivityStats(
      caloriesBurned:
          today.fold<double>(0, (s, a) => s + (a.caloriesKcal ?? 0)),
      activeMinutes:
          today.fold<double>(0, (s, a) => s + a.durationSeconds / 60).round(),
      distanceKm:
          today.fold<double>(0, (s, a) => s + a.distanceMeters / 1000),
      workouts: today.length,
    );
  }
}
