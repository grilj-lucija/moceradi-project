import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food.dart';

class FoodListTile extends StatelessWidget {
  const FoodListTile({
    required this.food,
    this.onTap,
    this.trailing,
    super.key,
  });

  final Food food;
  final VoidCallback? onTap;
  final Widget? trailing;

  IconData get _sourceIcon {
    if (food.isBeverage) return Icons.local_drink_outlined;
    return switch (food.source) {
      FoodSourceKind.openFoodFacts => Icons.qr_code_2,
      FoodSourceKind.generic => Icons.restaurant_outlined,
      FoodSourceKind.custom => Icons.edit_note,
      FoodSourceKind.recipe => Icons.menu_book_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final kcal = food.facts.kcalPer100g.round();
    final macro = '$kcal kcal${food.per100Suffix}';
    final subtitle = (food.brand?.isNotEmpty ?? false)
        ? '${food.brand} • $macro'
        : macro;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.lgRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.lgRadius,
        child: Ink(
          padding: EdgeInsets.all(spacing.stackMd),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: radius.lgRadius,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: radius.baseRadius,
                ),
                child: Icon(
                  _sourceIcon,
                  color: colors.enduranceCyan,
                  size: 22,
                ),
              ),
              SizedBox(width: spacing.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: typography.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: typography.bodyMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: spacing.stackSm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
