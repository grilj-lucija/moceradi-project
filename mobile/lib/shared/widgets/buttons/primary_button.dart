import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: spacing.touchTargetMin,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius.pill,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius.pill,
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? colors.primaryGradient
                  : LinearGradient(
                      colors: [
                        colors.surfaceContainerHigh,
                        colors.surfaceContainerHighest,
                      ],
                    ),
              borderRadius: radius.pill,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.white),
                          SizedBox(width: spacing.stackSm),
                        ],
                        Text(
                          label,
                          style: typography.labelMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
