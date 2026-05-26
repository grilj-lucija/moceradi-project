import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class MultiChoiceChipOption<T> {
  const MultiChoiceChipOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class MultiChoiceChips<T> extends StatelessWidget {
  const MultiChoiceChips({
    required this.options,
    required this.values,
    required this.onChanged,
    this.readOnly = false,
    super.key,
  });

  final List<MultiChoiceChipOption<T>> options;
  final Set<T> values;
  final ValueChanged<T>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Wrap(
      spacing: spacing.gutter / 2,
      runSpacing: spacing.gutter / 2,
      children: [
        for (final option in options)
          _ChipTile<T>(
            option: option,
            selected: values.contains(option.value),
            onTap: readOnly || onChanged == null
                ? null
                : () => onChanged!(option.value),
          ),
      ],
    );
  }
}

class _ChipTile<T> extends StatelessWidget {
  const _ChipTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MultiChoiceChipOption<T> option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final borderColor = selected ? colors.enduranceCyan : colors.ghostBorder;
    final fillColor = selected
        ? colors.enduranceCyan.withValues(alpha: 0.12)
        : colors.surfaceContainerLow;
    final iconColor = selected ? colors.enduranceCyan : colors.onSurfaceVariant;
    final labelColor = selected ? colors.onSurface : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.pill,
        child: Ink(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius.pill,
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackMd,
            vertical: spacing.stackSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 18, color: iconColor),
                SizedBox(width: spacing.stackSm),
              ],
              Text(
                option.label,
                style: typography.bodyMd.copyWith(color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
