import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/health/calorie_engine.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';

class OnboardingFormState extends Equatable {
  const OnboardingFormState({
    this.displayName = '',
    this.username = '',
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.intents = const {},
    this.targetWeightKg,
    this.activityMetric,
    this.activityTarget,
    this.pace = GoalPace.balanced,
    this.kcalOverride,
    this.isSubmitting = false,
  });

  final String displayName;
  final String username;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final Set<GoalType> intents;
  final double? targetWeightKg;
  final ActivityMetric? activityMetric;
  final double? activityTarget;
  final GoalPace pace;
  final double? kcalOverride;
  final bool isSubmitting;

  OnboardingFormState copyWith({
    String? displayName,
    String? username,
    Gender? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Set<GoalType>? intents,
    Object? targetWeightKg = _sentinel,
    ActivityMetric? activityMetric,
    Object? activityTarget = _sentinel,
    GoalPace? pace,
    Object? kcalOverride = _sentinel,
    bool? isSubmitting,
  }) =>
      OnboardingFormState(
        displayName: displayName ?? this.displayName,
        username: username ?? this.username,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        intents: intents ?? this.intents,
        targetWeightKg: identical(targetWeightKg, _sentinel)
            ? this.targetWeightKg
            : targetWeightKg as double?,
        activityMetric: activityMetric ?? this.activityMetric,
        activityTarget: identical(activityTarget, _sentinel)
            ? this.activityTarget
            : activityTarget as double?,
        pace: pace ?? this.pace,
        kcalOverride: identical(kcalOverride, _sentinel)
            ? this.kcalOverride
            : kcalOverride as double?,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  static const _sentinel = Object();

  Profile? get _previewProfile {
    if (gender == null ||
        dateOfBirth == null ||
        heightCm == null ||
        weightKg == null ||
        activityLevel == null) {
      return null;
    }
    final now = DateTime.now();
    return Profile(
      id: 'preview',
      createdAt: now,
      updatedAt: now,
      gender: gender,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      targetWeightKg: targetWeightKg,
    );
  }

  CaloriePlan? get caloriePlan {
    final preview = _previewProfile;
    if (preview == null) return null;
    return CalorieEngine.buildPlan(profile: preview, pace: pace);
  }

  double? get effectiveKcal {
    final override = kcalOverride;
    if (override != null) return override;
    return caloriePlan?.recommendedKcal;
  }

  double? get projectedWeeksAtEffectiveKcal {
    final preview = _previewProfile;
    final kcal = effectiveKcal;
    if (preview == null || kcal == null) return null;
    return CalorieEngine.projectWeeksToGoal(
      profile: preview,
      kcalPerDay: kcal,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        username,
        gender,
        dateOfBirth,
        heightCm,
        weightKg,
        activityLevel,
        intents,
        targetWeightKg,
        activityMetric,
        activityTarget,
        pace,
        kcalOverride,
        isSubmitting,
      ];
}

class OnboardingController extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  void setDisplayName(String value) =>
      state = state.copyWith(displayName: value);
  void setUsername(String value) => state = state.copyWith(username: value);
  void setGender(Gender value) => state = state.copyWith(gender: value);
  void setDateOfBirth(DateTime value) =>
      state = state.copyWith(dateOfBirth: value);
  void setHeight(double value) => state = state.copyWith(heightCm: value);
  void setWeight(double value) => state = state.copyWith(weightKg: value);
  void setActivityLevel(ActivityLevel value) =>
      state = state.copyWith(activityLevel: value);

  void toggleIntent(GoalType value) {
    final next = {...state.intents};
    if (!next.add(value)) next.remove(value);
    state = state.copyWith(intents: next);
  }

  void setTargetWeight(double? value) =>
      state = state.copyWith(targetWeightKg: value);

  void setActivityMetric(ActivityMetric value) {
    final keepTarget = state.activityMetric == value;
    state = state.copyWith(
      activityMetric: value,
      activityTarget: keepTarget ? state.activityTarget : value.defaultTarget,
    );
  }

  void setActivityTarget(double? value) =>
      state = state.copyWith(activityTarget: value);

  void setPace(GoalPace value) =>
      state = state.copyWith(pace: value, kcalOverride: null);

  void setKcalOverride(double? value) =>
      state = state.copyWith(kcalOverride: value);

  Future<Failure?> submit() async {
    state = state.copyWith(isSubmitting: true);
    final form = state;

    final profileResult = await ref.read(profileRepositoryProvider).upsert(
          username: form.username.trim(),
          displayName: form.displayName.trim(),
          gender: form.gender,
          dateOfBirth: form.dateOfBirth,
          heightCm: form.heightCm,
          weightKg: form.weightKg,
          activityLevel: form.activityLevel,
          targetWeightKg: form.targetWeightKg,
          markOnboarded: true,
        );
    final profileFailure = profileResult.fold(
      ok: (_) => null,
      err: (failure) => failure,
    );
    if (profileFailure != null) {
      state = state.copyWith(isSubmitting: false);
      return profileFailure;
    }

    final goalsResult = await ref.read(userGoalsRepositoryProvider).upsert(
          intents: form.intents.toList(),
          activityMetric: form.activityMetric,
          activityTarget: form.activityTarget,
          pace: form.pace,
          kcalOverride: form.kcalOverride != null,
        );
    final goalsFailure = goalsResult.fold(
      ok: (_) => null,
      err: (failure) => failure,
    );
    if (goalsFailure != null) {
      state = state.copyWith(isSubmitting: false);
      return goalsFailure;
    }

    final kcal = form.effectiveKcal;
    if (kcal != null) {
      await ref
          .read(nutritionLogRepositoryProvider)
          .updateDailyKcal(kcal.roundToDouble());
    }

    final weight = form.weightKg;
    if (weight != null) {
      await ref.read(weightRepositoryProvider).logCurrentWeek(weight);
    }

    state = state.copyWith(isSubmitting: false);
    ref
      ..invalidate(currentProfileProvider)
      ..invalidate(currentUserGoalsProvider)
      ..invalidate(dailyNutritionControllerProvider);
    return null;
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingFormState>(
  OnboardingController.new,
);
