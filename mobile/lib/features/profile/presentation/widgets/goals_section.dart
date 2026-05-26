import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';
import 'package:health_app/shared/widgets/inputs/multi_choice_chips.dart';

class GoalsSection extends ConsumerWidget {
  const GoalsSection({required this.profile, super.key});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final goalsAsync = ref.watch(currentUserGoalsProvider);
    final nutritionAsync = ref.watch(dailyNutritionControllerProvider);
    final goals = goalsAsync.value;
    final kcal = nutritionAsync.value?.goal.kcal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: colors.enduranceCyan,
                  ),
                  SizedBox(width: spacing.stackSm),
                  Text(
                    'GOALS',
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.stackMd),
              if ((goals?.intents ?? const []).isEmpty)
                Text(
                  'No goals set yet.',
                  style: typography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                )
              else
                MultiChoiceChips<GoalType>(
                  values: goals!.intents.toSet(),
                  onChanged: null,
                  readOnly: true,
                  options: [
                    for (final goal in goals.intents)
                      MultiChoiceChipOption<GoalType>(
                        value: goal,
                        label: goal.label,
                        icon: goal.icon,
                      ),
                  ],
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.stackMd),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: _activityLabel(goals),
                value: _activityValue(goals),
                unit: _activityUnit(goals),
                icon: goals?.activityMetric?.icon ?? Icons.directions_run,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Daily intake',
                value: kcal == null ? '—' : kcal.round().toString(),
                unit: kcal == null ? null : 'kcal',
                icon: Icons.restaurant_menu,
                highlight: true,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackMd),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Target weight',
                value: profile?.targetWeightKg == null
                    ? '—'
                    : profile!.targetWeightKg!.toStringAsFixed(0),
                unit: profile?.targetWeightKg == null ? null : 'kg',
                icon: Icons.center_focus_strong_outlined,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Activity level',
                value: profile?.activityLevel?.label ?? '—',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackMd),
        GhostButton(
          label: 'Edit goals & plan',
          icon: Icons.tune,
          onPressed: () => context.push(AppRoutes.editGoals),
        ),
      ],
    );
  }

  String _activityLabel(UserGoals? g) =>
      g?.activityMetric?.shortLabel ?? 'Activity goal';

  String _activityValue(UserGoals? g) {
    final t = g?.activityTarget;
    final m = g?.activityMetric;
    if (t == null || m == null) return '—';
    return m.isInteger ? t.toStringAsFixed(0) : t.toStringAsFixed(1);
  }

  String? _activityUnit(UserGoals? g) {
    final m = g?.activityMetric;
    if (m == null || g?.activityTarget == null) return null;
    return m.unitPerWeek;
  }
}
