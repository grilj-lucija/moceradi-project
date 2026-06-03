import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.highlight = false,
    super.key,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final valueColor = highlight ? colors.enduranceCyan : colors.onSurface;

    return Container(
      padding: EdgeInsets.all(spacing.stackLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: colors.velocityBlue.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.onSurfaceVariant),
                SizedBox(width: spacing.stackSm),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: typography.labelMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: typography.metricXl.copyWith(color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: spacing.stackSm / 2),
                Text(
                  unit!,
                  style: typography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
