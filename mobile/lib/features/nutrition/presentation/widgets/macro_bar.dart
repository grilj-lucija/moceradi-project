import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class MacroBar extends StatelessWidget {
  const MacroBar({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.proteinGoalGrams,
    required this.carbsGoalGrams,
    required this.fatGoalGrams,
    super.key,
  });

  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double proteinGoalGrams;
  final double carbsGoalGrams;
  final double fatGoalGrams;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      children: [
        Expanded(
          child: _MacroPill(
            label: 'Protein',
            grams: proteinGrams,
            goalGrams: proteinGoalGrams,
            color: colors.chartProtein,
          ),
        ),
        SizedBox(width: spacing.gutter / 2),
        Expanded(
          child: _MacroPill(
            label: 'Carbs',
            grams: carbsGrams,
            goalGrams: carbsGoalGrams,
            color: colors.chartCarbs,
          ),
        ),
        SizedBox(width: spacing.gutter / 2),
        Expanded(
          child: _MacroPill(
            label: 'Fat',
            grams: fatGrams,
            goalGrams: fatGoalGrams,
            color: colors.chartFat,
          ),
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.grams,
    required this.goalGrams,
    required this.color,
  });

  final String label;
  final double grams;
  final double goalGrams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final progress =
        goalGrams <= 0 ? 0.0 : (grams / goalGrams).clamp(0, 1).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackMd,
        vertical: spacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: typography.labelMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            '${grams.round()}g',
            style: typography.titleMd,
          ),
          Text(
            'of ${goalGrams.round()}g',
            style: typography.bodyMd.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          SizedBox(height: spacing.stackSm),
          ClipRRect(
            borderRadius: radius.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
