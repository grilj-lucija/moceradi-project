import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GoalType {
  loseWeight,
  gainWeight,
  buildEndurance,
  improveGeneralFitness,
  runA5k,
  buildStrength,
}

extension GoalTypeX on GoalType {
  String get wireValue => switch (this) {
        GoalType.loseWeight => 'lose_weight',
        GoalType.gainWeight => 'gain_weight',
        GoalType.buildEndurance => 'build_endurance',
        GoalType.improveGeneralFitness => 'improve_general_fitness',
        GoalType.runA5k => 'run_a_5k',
        GoalType.buildStrength => 'build_strength',
      };

  String get label => switch (this) {
        GoalType.loseWeight => 'Lose weight',
        GoalType.gainWeight => 'Gain weight',
        GoalType.buildEndurance => 'Build endurance',
        GoalType.improveGeneralFitness => 'General fitness',
        GoalType.runA5k => 'Run a 5K',
        GoalType.buildStrength => 'Build strength',
      };

  IconData get icon => switch (this) {
        GoalType.loseWeight => Icons.trending_down,
        GoalType.gainWeight => Icons.trending_up,
        GoalType.buildEndurance => Icons.directions_run,
        GoalType.improveGeneralFitness => Icons.favorite_outline,
        GoalType.runA5k => Icons.flag_outlined,
        GoalType.buildStrength => Icons.fitness_center,
      };

  static GoalType? fromWire(String? value) {
    if (value == null) return null;
    for (final g in GoalType.values) {
      if (g.wireValue == value) return g;
    }
    return null;
  }
}

enum ActivityMetric {
  cyclingDistance,
  runningDistance,
  walkingDistance,
  activeMinutes,
  caloriesBurned,
  workouts,
}

extension ActivityMetricX on ActivityMetric {
  String get wireValue => switch (this) {
        ActivityMetric.cyclingDistance => 'cycling_distance',
        ActivityMetric.runningDistance => 'running_distance',
        ActivityMetric.walkingDistance => 'walking_distance',
        ActivityMetric.activeMinutes => 'active_minutes',
        ActivityMetric.caloriesBurned => 'calories_burned',
        ActivityMetric.workouts => 'workouts',
      };

  String get label => switch (this) {
        ActivityMetric.cyclingDistance => 'Cycling distance',
        ActivityMetric.runningDistance => 'Running distance',
        ActivityMetric.walkingDistance => 'Walking distance',
        ActivityMetric.activeMinutes => 'Active time',
        ActivityMetric.caloriesBurned => 'Calories burned',
        ActivityMetric.workouts => 'Workouts',
      };

  String get shortLabel => switch (this) {
        ActivityMetric.cyclingDistance => 'Cycling',
        ActivityMetric.runningDistance => 'Running',
        ActivityMetric.walkingDistance => 'Walking',
        ActivityMetric.activeMinutes => 'Active time',
        ActivityMetric.caloriesBurned => 'Calories',
        ActivityMetric.workouts => 'Workouts',
      };

  IconData get icon => switch (this) {
        ActivityMetric.cyclingDistance => Icons.directions_bike,
        ActivityMetric.runningDistance => Icons.directions_run,
        ActivityMetric.walkingDistance => Icons.directions_walk,
        ActivityMetric.activeMinutes => Icons.timer_outlined,
        ActivityMetric.caloriesBurned => Icons.local_fire_department_outlined,
        ActivityMetric.workouts => Icons.fitness_center,
      };

  String get unit => switch (this) {
        ActivityMetric.cyclingDistance ||
        ActivityMetric.runningDistance ||
        ActivityMetric.walkingDistance =>
          'km',
        ActivityMetric.activeMinutes => 'min',
        ActivityMetric.caloriesBurned => 'kcal',
        ActivityMetric.workouts => '',
      };

  String get unitPerWeek => switch (this) {
        ActivityMetric.cyclingDistance ||
        ActivityMetric.runningDistance ||
        ActivityMetric.walkingDistance =>
          'km / wk',
        ActivityMetric.activeMinutes => 'min / wk',
        ActivityMetric.caloriesBurned => 'kcal / wk',
        ActivityMetric.workouts => '/ wk',
      };

  double get defaultTarget => switch (this) {
        ActivityMetric.cyclingDistance => 60,
        ActivityMetric.runningDistance => 20,
        ActivityMetric.walkingDistance => 35,
        ActivityMetric.activeMinutes => 150,
        ActivityMetric.caloriesBurned => 2000,
        ActivityMetric.workouts => 4,
      };

  bool get isInteger =>
      this == ActivityMetric.activeMinutes ||
      this == ActivityMetric.caloriesBurned ||
      this == ActivityMetric.workouts;

  static ActivityMetric? fromWire(String? value) {
    if (value == null) return null;
    for (final m in ActivityMetric.values) {
      if (m.wireValue == value) return m;
    }
    return null;
  }
}

enum GoalPace { easy, balanced, aggressive }

extension GoalPaceX on GoalPace {
  String get wireValue => name;

  String get label => switch (this) {
        GoalPace.easy => 'Easy',
        GoalPace.balanced => 'Balanced',
        GoalPace.aggressive => 'Aggressive',
      };

  double get kgPerWeek => switch (this) {
        GoalPace.easy => 0.25,
        GoalPace.balanced => 0.5,
        GoalPace.aggressive => 0.75,
      };

  String get description => switch (this) {
        GoalPace.easy => 'Steady — easy to sustain',
        GoalPace.balanced => 'Balanced — recommended',
        GoalPace.aggressive => 'Fast — harder to keep up',
      };

  static GoalPace? fromWire(String? value) {
    if (value == null) return null;
    for (final p in GoalPace.values) {
      if (p.name == value) return p;
    }
    return null;
  }
}

class UserGoals extends Equatable {
  const UserGoals({
    required this.userId,
    this.intents = const [],
    this.activityMetric,
    this.activityTarget,
    this.activityPeriod = 'week',
    this.pace = GoalPace.balanced,
    this.kcalOverride = false,
    this.updatedAt,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) => UserGoals(
        userId: json['user_id'] as String,
        intents: (json['intents'] as List?)
                ?.map((e) => GoalTypeX.fromWire(e as String?))
                .whereType<GoalType>()
                .toList() ??
            const [],
        activityMetric:
            ActivityMetricX.fromWire(json['activity_metric'] as String?),
        activityTarget: (json['activity_target'] as num?)?.toDouble(),
        activityPeriod: (json['activity_period'] as String?) ?? 'week',
        pace: GoalPaceX.fromWire(json['pace'] as String?) ?? GoalPace.balanced,
        kcalOverride: (json['kcal_override'] as bool?) ?? false,
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  final String userId;
  final List<GoalType> intents;
  final ActivityMetric? activityMetric;
  final double? activityTarget;
  final String activityPeriod;
  final GoalPace pace;
  final bool kcalOverride;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'intents': intents.map((g) => g.wireValue).toList(),
        'activity_metric': activityMetric?.wireValue,
        'activity_target': activityTarget,
        'activity_period': activityPeriod,
        'pace': pace.wireValue,
        'kcal_override': kcalOverride,
        'updated_at': updatedAt?.toIso8601String(),
      };

  UserGoals copyWith({
    List<GoalType>? intents,
    Object? activityMetric = _sentinel,
    Object? activityTarget = _sentinel,
    String? activityPeriod,
    GoalPace? pace,
    bool? kcalOverride,
    DateTime? updatedAt,
  }) =>
      UserGoals(
        userId: userId,
        intents: intents ?? this.intents,
        activityMetric: identical(activityMetric, _sentinel)
            ? this.activityMetric
            : activityMetric as ActivityMetric?,
        activityTarget: identical(activityTarget, _sentinel)
            ? this.activityTarget
            : activityTarget as double?,
        activityPeriod: activityPeriod ?? this.activityPeriod,
        pace: pace ?? this.pace,
        kcalOverride: kcalOverride ?? this.kcalOverride,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
        userId,
        intents,
        activityMetric,
        activityTarget,
        activityPeriod,
        pace,
        kcalOverride,
        updatedAt,
      ];
}
