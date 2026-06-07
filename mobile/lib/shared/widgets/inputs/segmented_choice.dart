import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class SegmentedChoiceOption<T> {
  const SegmentedChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<SegmentedChoiceOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: spacing.gutter / 2),
          Expanded(
            child: _SegmentTile<T>(
              option: options[i],
              selected: options[i].value == value,
              onTap: () => onChanged(options[i].value),
            ),
          ),
        ],
      ],
    );
  }
}

class _SegmentTile<T> extends StatelessWidget {
  const _SegmentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SegmentedChoiceOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final borderColor = selected ? colors.velocityBlue : colors.ghostBorder;
    final iconColor = selected ? colors.enduranceCyan : colors.onSurfaceVariant;
    final labelColor = selected ? colors.onSurface : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.mdRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.mdRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? colors.surfaceContainerHigh
                : colors.surfaceContainerLow,
            borderRadius: radius.mdRadius,
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.velocityBlue.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackMd,
            vertical: spacing.stackMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 22, color: iconColor),
                SizedBox(height: spacing.stackSm / 2),
              ],
              Text(
                option.label,
                style: typography.bodyMd.copyWith(color: labelColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
