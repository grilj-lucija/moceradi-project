import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor,
    this.iconSize,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    return ClipRRect(
      borderRadius: radius.pill,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: colors.surfaceContainer.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: radius.pill,
            side: BorderSide(color: colors.ghostBorder),
          ),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: iconColor ?? colors.onSurface,
              size: iconSize,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
