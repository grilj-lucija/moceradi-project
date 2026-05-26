import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/models/user_goals.dart';

const double _kcalPerKg = 7700;
const double _minMaleKcal = 1500;
const double _minFemaleKcal = 1200;
const double _minOtherKcal = 1350;

enum CaloriePlanDirection { lose, maintain, gain }

class CaloriePlan extends Equatable {
  const CaloriePlan({
    required this.bmr,
    required this.tdee,
    required this.recommendedKcal,
    required this.dailyDelta,
    required this.direction,
    required this.weeksToGoal,
    required this.minSafeKcal,
  });

  final double bmr;
  final double tdee;
  final double recommendedKcal;
  final double dailyDelta;
  final CaloriePlanDirection direction;
  final double? weeksToGoal;
  final double minSafeKcal;

  bool get isMaintenance => direction == CaloriePlanDirection.maintain;

  @override
  List<Object?> get props => [
        bmr,
        tdee,
        recommendedKcal,
        dailyDelta,
        direction,
        weeksToGoal,
        minSafeKcal,
      ];
}

class CalorieEngine {
  const CalorieEngine._();

  static double? computeBmr({
    required Gender? gender,
    required double? weightKg,
    required double? heightCm,
    required int? age,
  }) {
    if (weightKg == null || heightCm == null || age == null) return null;
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return switch (gender) {
      Gender.male => base + 5,
      Gender.female => base - 161,
      Gender.other || null => base - 78,
    };
  }

  static double minSafeKcal(Gender? gender) => switch (gender) {
        Gender.male => _minMaleKcal,
        Gender.female => _minFemaleKcal,
        Gender.other || null => _minOtherKcal,
      };

  static CaloriePlan? buildPlan({
    required Profile profile,
    required GoalPace pace,
  }) {
    final bmr = computeBmr(
      gender: profile.gender,
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
    );
    final activity = profile.activityLevel;
    if (bmr == null || activity == null) return null;

    final tdee = bmr * activity.tdeeMultiplier;
    final currentKg = profile.weightKg!;
    final targetKg = profile.targetWeightKg;
    final minSafe = minSafeKcal(profile.gender);

    if (targetKg == null || (targetKg - currentKg).abs() < 0.1) {
      return CaloriePlan(
        bmr: bmr,
        tdee: tdee,
        recommendedKcal: tdee,
        dailyDelta: 0,
        direction: CaloriePlanDirection.maintain,
        weeksToGoal: null,
        minSafeKcal: minSafe,
      );
    }

    final isLoss = targetKg < currentKg;
    final dailyDelta = pace.kgPerWeek * _kcalPerKg / 7;
    final signedDelta = isLoss ? -dailyDelta : dailyDelta;
    var recommended = tdee + signedDelta;

    if (isLoss && recommended < minSafe) {
      recommended = minSafe;
    }

    final effectiveDelta = recommended - tdee;
    final weeklyKgChange = (effectiveDelta * 7).abs() / _kcalPerKg;
    final weeksToGoal =
        weeklyKgChange <= 0 ? null : (currentKg - targetKg).abs() / weeklyKgChange;

    return CaloriePlan(
      bmr: bmr,
      tdee: tdee,
      recommendedKcal: recommended,
      dailyDelta: effectiveDelta,
      direction: isLoss
          ? CaloriePlanDirection.lose
          : CaloriePlanDirection.gain,
      weeksToGoal: weeksToGoal,
      minSafeKcal: minSafe,
    );
  }

  static double? projectWeeksToGoal({
    required Profile profile,
    required double kcalPerDay,
  }) {
    final bmr = computeBmr(
      gender: profile.gender,
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
    );
    final activity = profile.activityLevel;
    final targetKg = profile.targetWeightKg;
    final currentKg = profile.weightKg;
    if (bmr == null ||
        activity == null ||
        targetKg == null ||
        currentKg == null) {
      return null;
    }
    final tdee = bmr * activity.tdeeMultiplier;
    final dailyDelta = kcalPerDay - tdee;
    if (dailyDelta == 0) return null;
    final isLoss = targetKg < currentKg;
    if (isLoss && dailyDelta >= 0) return null;
    if (!isLoss && dailyDelta <= 0) return null;
    final weeklyKgChange = (dailyDelta * 7).abs() / _kcalPerKg;
    if (weeklyKgChange <= 0) return null;
    return (currentKg - targetKg).abs() / weeklyKgChange;
  }
}
