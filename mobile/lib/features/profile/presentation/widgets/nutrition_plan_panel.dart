import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/health/calorie_engine.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';
import 'package:health_app/shared/widgets/inputs/segmented_choice.dart';

class NutritionPlanPanel extends StatefulWidget {
  const NutritionPlanPanel({
    required this.plan,
    required this.pace,
    required this.effectiveKcal,
    required this.kcalOverride,
    required this.projectedWeeks,
    required this.onPaceChanged,
    required this.onKcalOverrideChanged,
    super.key,
  });

  final CaloriePlan? plan;
  final GoalPace pace;
  final double? effectiveKcal;
  final double? kcalOverride;
  final double? projectedWeeks;
  final ValueChanged<GoalPace> onPaceChanged;
  final ValueChanged<double?> onKcalOverrideChanged;

  @override
  State<NutritionPlanPanel> createState() => _NutritionPlanPanelState();
}

class _NutritionPlanPanelState extends State<NutritionPlanPanel> {
  late final TextEditingController _kcalController;

  @override
  void initState() {
    super.initState();
    _kcalController = TextEditingController(
      text: widget.effectiveKcal == null
          ? ''
          : widget.effectiveKcal!.round().toString(),
    );
  }

  @override
  void didUpdateWidget(covariant NutritionPlanPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.effectiveKcal;
    if (next != null) {
      final text = next.round().toString();
      if (_kcalController.text != text &&
          !_kcalController.selection.isValid) {
        _kcalController.text = text;
      } else if (widget.kcalOverride == null &&
          _kcalController.text != text) {
        _kcalController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _kcalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final plan = widget.plan;

    if (plan == null) {
      return GlassCard(
        child: Text(
          'Complete the previous steps to see your personalised plan.',
          style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'BMR',
                value: plan.bmr.round().toString(),
                unit: 'kcal',
                icon: Icons.bolt_outlined,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Maintenance',
                value: plan.tdee.round().toString(),
                unit: 'kcal',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        if (!plan.isMaintenance) ...[
          SizedBox(height: spacing.stackLg),
          Text(
            'PACE',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          SegmentedChoice<GoalPace>(
            value: widget.pace,
            onChanged: widget.onPaceChanged,
            options: const [
              SegmentedChoiceOption(value: GoalPace.easy, label: 'Easy'),
              SegmentedChoiceOption(
                value: GoalPace.balanced,
                label: 'Balanced',
              ),
              SegmentedChoiceOption(
                value: GoalPace.aggressive,
                label: 'Hard',
              ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            widget.pace.description,
            style: typography.labelMd.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
        SizedBox(height: spacing.stackLg),
        GlassCard(
          tint: colors.surfaceContainer.withValues(alpha: 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: colors.enduranceCyan,
                    size: 18,
                  ),
                  SizedBox(width: spacing.stackSm),
                  Text(
                    'DAILY CALORIES',
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  if (widget.kcalOverride != null)
                    TextButton(
                      onPressed: () => widget.onKcalOverrideChanged(null),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.stackSm,
                          vertical: 0,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        'Reset',
                        style: typography.labelMd.copyWith(
                          color: colors.enduranceCyan,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing.stackMd),
              TextField(
                controller: _kcalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: typography.metricXl.copyWith(
                  color: colors.enduranceCyan,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  if (v.isEmpty) {
                    widget.onKcalOverrideChanged(null);
                    return;
                  }
                  final parsed = double.tryParse(v);
                  if (parsed != null) widget.onKcalOverrideChanged(parsed);
                },
              ),
              SizedBox(height: spacing.stackSm),
              Center(
                child: Text(
                  'kcal / day',
                  style: typography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: spacing.stackMd),
              _Projection(
                plan: plan,
                effectiveKcal: widget.effectiveKcal,
                projectedWeeks: widget.projectedWeeks,
                kcalOverride: widget.kcalOverride,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Projection extends StatelessWidget {
  const _Projection({
    required this.plan,
    required this.effectiveKcal,
    required this.projectedWeeks,
    required this.kcalOverride,
  });

  final CaloriePlan plan;
  final double? effectiveKcal;
  final double? projectedWeeks;
  final double? kcalOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    if (plan.isMaintenance) {
      return _row(
        context,
        icon: Icons.check_circle_outline,
        color: colors.enduranceCyan,
        text: 'Maintain your current weight at this intake.',
      );
    }

    final kcal = effectiveKcal;
    if (kcal == null) {
      return const SizedBox.shrink();
    }

    if (kcalOverride != null) {
      final isLoss = plan.direction == CaloriePlanDirection.lose;
      final maintains = (kcal - plan.tdee).abs() < 25;
      if (maintains) {
        return _row(
          context,
          icon: Icons.info_outline,
          color: colors.onSurfaceVariant,
          text: 'At ${kcal.round()} kcal you will maintain, not reach your target.',
        );
      }
      final goingWrongWay = isLoss ? kcal > plan.tdee : kcal < plan.tdee;
      if (goingWrongWay) {
        return _row(
          context,
          icon: Icons.warning_amber_rounded,
          color: colors.error,
          text: 'This intake moves you away from your target weight.',
        );
      }
    }

    final weeks = projectedWeeks;
    final isLoss = plan.direction == CaloriePlanDirection.lose;
    final verb = isLoss ? 'lose' : 'gain';

    if (weeks == null) {
      return _row(
        context,
        icon: Icons.timeline,
        color: colors.onSurfaceVariant,
        text: 'Adjust intake to start making progress.',
      );
    }

    final months = weeks / 4.345;
    final timeText = months >= 1.5
        ? '${months.toStringAsFixed(months >= 6 ? 0 : 1)} months'
        : '${weeks.round()} weeks';

    if (kcal <= plan.minSafeKcal + 1 && isLoss) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            context,
            icon: Icons.shield_outlined,
            color: colors.enduranceCyan,
            text: "We've capped you at ${plan.minSafeKcal.round()} kcal for safety.",
          ),
          SizedBox(height: spacing.stackSm / 2),
          Text(
            "You'll $verb weight in about $timeText.",
            style: typography.bodyMd,
          ),
        ],
      );
    }

    return _row(
      context,
      icon: Icons.timeline,
      color: colors.enduranceCyan,
      text: "You'll $verb your target in about $timeText.",
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    final spacing = context.spacing;
    final typography = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: spacing.stackSm),
        Expanded(
          child: Text(text, style: typography.bodyMd),
        ),
      ],
    );
  }
}
