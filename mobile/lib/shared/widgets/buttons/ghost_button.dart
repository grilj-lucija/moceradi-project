import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final enabled = onPressed != null;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: spacing.touchTargetMin,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: enabled ? colors.enduranceCyan : colors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius.pill),
          padding: EdgeInsets.symmetric(horizontal: spacing.stackLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: enabled ? colors.enduranceCyan : colors.outline,
              ),
              SizedBox(width: spacing.stackSm),
            ],
            Text(
              label,
              style: typography.labelMd.copyWith(
                color: enabled ? colors.enduranceCyan : colors.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
