import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({
    required this.consumedKcal,
    required this.goalKcal,
    this.size = 200,
    super.key,
  });

  final double consumedKcal;
  final double goalKcal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final progress = goalKcal <= 0 ? 0.0 : (consumedKcal / goalKcal);
    final remaining = (goalKcal - consumedKcal).clamp(0, double.infinity);
    final remainingLabel = remaining == 0 ? 'Goal reached' : 'remaining';

    return ProgressRing(
      progress: progress,
      size: size,
      strokeWidth: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CALORIES',
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm / 2),
          Text(
            consumedKcal.round().toString(),
            style: typography.metricXl.copyWith(
              color: colors.enduranceCyan,
            ),
          ),
          Text(
            'of ${goalKcal.round()} kcal',
            style: typography.bodyMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm / 2),
          Text(
            remaining == 0
                ? remainingLabel
                : '${remaining.round()} $remainingLabel',
            style: typography.labelMd.copyWith(
              color: remaining == 0
                  ? colors.enduranceCyan
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
