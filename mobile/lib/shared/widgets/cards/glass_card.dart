import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 20,
    this.tint,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;
    final br = borderRadius ?? radius.xlRadius;

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(spacing.stackLg),
          decoration: BoxDecoration(
            color: tint ?? colors.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: br,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
