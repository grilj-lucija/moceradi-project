import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';
import 'package:intl/intl.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({
    required this.consumedKcal,
    required this.goalKcal,
    this.size = 180,
    super.key,
  });

  final double consumedKcal;
  final double goalKcal;
  final double size;

  static final _fmt = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final hasGoal = goalKcal > 0;
    final diff = consumedKcal - goalKcal;
    final isOver = hasGoal && diff > 0;
    final remaining =
        hasGoal ? (goalKcal - consumedKcal).clamp(0.0, double.infinity) : 0.0;
    final progress = hasGoal ? consumedKcal / goalKcal : 0.0;

    final eaten = _fmt.format(consumedKcal.round());
    final goal = _fmt.format(goalKcal.round());
    final footerNumber = isOver
        ? _fmt.format(diff.round())
        : _fmt.format(remaining.round());
    final footerLabel = isOver ? 'kcal over' : 'kcal left';
    final footerColor = isOver ? colors.error : colors.enduranceCyan;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          progress: progress,
          size: size,
          strokeWidth: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eaten,
                style: typography.metricXl.copyWith(color: colors.onSurface),
              ),
              SizedBox(height: spacing.stackSm / 2),
              Text(
                hasGoal ? 'of $goal kcal' : 'kcal logged',
                style: typography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (hasGoal) ...[
          SizedBox(height: spacing.stackMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                footerNumber,
                style: typography.titleMd.copyWith(color: footerColor),
              ),
              const SizedBox(width: 6),
              Text(
                footerLabel,
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
