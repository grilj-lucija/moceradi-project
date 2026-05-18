import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.containerMarginMobile,
          vertical: spacing.stackSm,
        ),
        child: ClipRRect(
          borderRadius: radius.pill,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceContainer.withValues(alpha: 0.65),
                borderRadius: radius.pill,
                border: Border.all(color: colors.ghostBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final selected = i == currentIndex;
                  final color =
                      selected ? colors.enduranceCyan : colors.onSurfaceVariant;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(i),
                      borderRadius: radius.pill,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 22, color: color),
                          SizedBox(height: spacing.stackSm / 2),
                          Text(
                            item.label,
                            style: typography.labelMd.copyWith(
                              color: color,
                              fontSize: 11,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
