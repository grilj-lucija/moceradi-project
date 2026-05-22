import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class LiquidsCard extends StatelessWidget {
  const LiquidsCard({
    required this.consumedMl,
    required this.goalMl,
    super.key,
  });

  final double consumedMl;
  final double goalMl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final progress =
        goalMl <= 0 ? 0.0 : (consumedMl / goalMl).clamp(0, 1).toDouble();
    final consumedL = consumedMl / 1000;
    final goalL = goalMl / 1000;

    return Container(
      padding: EdgeInsets.all(spacing.stackMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: colors.velocityBlue,
                size: 20,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'LIQUIDS',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${consumedMl.round()} / ${goalMl.round()} ml',
                style: typography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                consumedL.toStringAsFixed(consumedL >= 10 ? 1 : 2),
                style: typography.headlineLg.copyWith(
                  color: colors.velocityBlue,
                ),
              ),
              SizedBox(width: spacing.stackSm / 2),
              Text(
                'L',
                style: typography.titleMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'of ${goalL.toStringAsFixed(1)} L',
                style: typography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          ClipRRect(
            borderRadius: radius.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(colors.velocityBlue),
            ),
          ),
        ],
      ),
    );
  }
}
