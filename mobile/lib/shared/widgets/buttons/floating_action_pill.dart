import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class FloatingActionPill extends StatelessWidget {
  const FloatingActionPill({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  static const double _pillHeight = 44;

  static double bottomOffset(BuildContext context) {
    final spacing = context.spacing;
    final navInset = MediaQuery.paddingOf(context).bottom;
    return navInset + spacing.stackSm;
  }

  static double reservedListPadding(BuildContext context) {
    final spacing = context.spacing;
    return bottomOffset(context) + _pillHeight + spacing.stackLg;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final enabled = onPressed != null && !isLoading;

    final background =
        enabled ? colors.enduranceCyan : colors.surfaceContainerHigh;
    final foreground =
        enabled ? colors.onPrimary : colors.onSurfaceVariant;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset(context),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: background,
          shape: StadiumBorder(
            side: BorderSide(
              color: enabled
                  ? colors.enduranceCyan.withValues(alpha: 0.25)
                  : colors.ghostBorder,
              width: 1,
            ),
          ),
          elevation: enabled ? 4 : 0,
          shadowColor: enabled
              ? colors.enduranceCyan.withValues(alpha: 0.25)
              : Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.stackLg,
                vertical: spacing.stackSm + 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  else
                    Icon(icon, size: 18, color: foreground),
                  SizedBox(width: spacing.stackSm),
                  Text(
                    label,
                    style: typography.labelMd.copyWith(
                      color: foreground,
                      fontSize: 14,
                      letterSpacing: 0.3,
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
