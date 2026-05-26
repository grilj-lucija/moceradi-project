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

  static double metricValue(
    ActivityMetric metric,
    List<Activity> activities,
  ) {
    switch (metric) {
      case ActivityMetric.cyclingDistance:
        return activities
            .where((a) => a.type == ActivityType.cycling)
            .fold<double>(0, (s, a) => s + a.distanceMeters / 1000);
      case ActivityMetric.runningDistance:
        return activities
            .where((a) => a.type == ActivityType.running)
            .fold<double>(0, (s, a) => s + a.distanceMeters / 1000);
      case ActivityMetric.walkingDistance:
        return activities
            .where((a) => a.type == ActivityType.walking)
            .fold<double>(0, (s, a) => s + a.distanceMeters / 1000);
      case ActivityMetric.activeMinutes:
        return activities.fold<double>(
          0,
          (s, a) => s + a.durationSeconds / 60,
        );
      case ActivityMetric.caloriesBurned:
        return activities.fold<double>(
          0,
          (s, a) => s + (a.caloriesKcal ?? 0),
        );
      case ActivityMetric.workouts:
        return activities.length.toDouble();
    }
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
