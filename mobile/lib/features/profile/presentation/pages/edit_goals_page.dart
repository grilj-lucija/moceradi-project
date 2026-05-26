import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/health/calorie_engine.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/features/profile/presentation/widgets/goals_form.dart';
import 'package:health_app/features/profile/presentation/widgets/nutrition_plan_panel.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';

class EditGoalsPage extends ConsumerStatefulWidget {
  const EditGoalsPage({super.key});

  @override
  ConsumerState<EditGoalsPage> createState() => _EditGoalsPageState();
}

class _EditGoalsPageState extends ConsumerState<EditGoalsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _attempted = false;
  bool _submitting = false;
  bool _seeded = false;
  String? _errorText;

  Set<GoalType> _intents = {};
  double? _targetWeightKg;
  ActivityMetric? _activityMetric;
  double? _activityTarget;
  GoalPace _pace = GoalPace.balanced;
  double? _kcalOverride;

  Profile? _baseProfile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final profile = ref.read(currentProfileProvider).value;
    final goals = ref.read(currentUserGoalsProvider).value;
    final kcal = ref.read(dailyNutritionControllerProvider).value?.goal.kcal;
    if (profile == null) return;
    _baseProfile = profile;
    _targetWeightKg = profile.targetWeightKg;
    if (goals != null) {
      _intents = goals.intents.toSet();
      _activityMetric = goals.activityMetric;
      _activityTarget = goals.activityTarget;
      _pace = goals.pace;
      if (goals.kcalOverride && kcal != null) _kcalOverride = kcal;
    }
    _seeded = true;
  }

  Profile? get _previewProfile {
    final base = _baseProfile;
    if (base == null) return null;
    return base.copyWith(targetWeightKg: _targetWeightKg);
  }

  CaloriePlan? get _plan {
    final p = _previewProfile;
    if (p == null) return null;
    return CalorieEngine.buildPlan(profile: p, pace: _pace);
  }

  double? get _effectiveKcal => _kcalOverride ?? _plan?.recommendedKcal;

  double? get _projectedWeeks {
    final p = _previewProfile;
    final kcal = _effectiveKcal;
    if (p == null || kcal == null) return null;
    return CalorieEngine.projectWeeksToGoal(profile: p, kcalPerDay: kcal);
  }

  void _toggleIntent(GoalType value) {
    setState(() {
      final next = {..._intents};
      if (!next.add(value)) next.remove(value);
      _intents = next;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _attempted = true;
      _errorText = null;
    });
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _intents.isEmpty || _activityMetric == null) {
      setState(() => _errorText = 'Please complete every field.');
      return;
    }
    final kcal = _effectiveKcal;
    if (kcal == null) {
      setState(() => _errorText = 'Could not compute a plan.');
      return;
    }

    setState(() => _submitting = true);

    final profileResult = await ref.read(profileRepositoryProvider).upsert(
          targetWeightKg: _targetWeightKg,
        );
    final profileFailure = profileResult.fold(
      ok: (_) => null,
      err: (f) => f,
    );
    if (profileFailure != null) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = profileFailure.message;
      });
      return;
    }

    final goalsResult = await ref.read(userGoalsRepositoryProvider).upsert(
          intents: _intents.toList(),
          activityMetric: _activityMetric,
          activityTarget: _activityTarget,
          pace: _pace,
          kcalOverride: _kcalOverride != null,
        );
    final goalsFailure = goalsResult.fold(
      ok: (_) => null,
      err: (f) => f,
    );
    if (goalsFailure != null) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = goalsFailure.message;
      });
      return;
    }

    await ref
        .read(nutritionLogRepositoryProvider)
        .updateDailyKcal(kcal.roundToDouble());

    if (!mounted) return;
    setState(() => _submitting = false);
    ref
      ..invalidate(currentProfileProvider)
      ..invalidate(currentUserGoalsProvider)
      ..invalidate(dailyNutritionControllerProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit goals & plan')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.containerMarginMobile,
            spacing.stackMd,
            spacing.containerMarginMobile,
            spacing.stackLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GoalsForm(
                        formKey: _formKey,
                        autovalidateMode: _attempted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        intents: _intents,
                        targetWeightKg: _targetWeightKg,
                        currentWeightKg: _baseProfile?.weightKg,
                        activityMetric: _activityMetric,
                        activityTarget: _activityTarget,
                        onToggleIntent: _toggleIntent,
                        onTargetWeightChanged: (v) =>
                            setState(() => _targetWeightKg = v),
                        onActivityMetricChanged: (m) {
                          setState(() {
                            final keep = _activityMetric == m;
                            _activityMetric = m;
                            if (!keep) _activityTarget = m.defaultTarget;
                          });
                        },
                        onActivityTargetChanged: (v) =>
                            setState(() => _activityTarget = v),
                        showHeader: false,
                      ),
                      SizedBox(height: spacing.sectionGap),
                      Text(
                        'NUTRITION PLAN',
                        style: typography.labelMd.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: spacing.stackMd),
                      NutritionPlanPanel(
                        plan: _plan,
                        pace: _pace,
                        effectiveKcal: _effectiveKcal,
                        kcalOverride: _kcalOverride,
                        projectedWeeks: _projectedWeeks,
                        onPaceChanged: (p) => setState(() {
                          _pace = p;
                          _kcalOverride = null;
                        }),
                        onKcalOverrideChanged: (v) =>
                            setState(() => _kcalOverride = v),
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorText != null) ...[
                SizedBox(height: spacing.stackMd),
                Text(
                  _errorText!,
                  style: typography.bodyMd.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: spacing.stackMd),
              PrimaryButton(
                label: 'Save',
                icon: Icons.check,
                isLoading: _submitting,
                onPressed: _submitting ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
