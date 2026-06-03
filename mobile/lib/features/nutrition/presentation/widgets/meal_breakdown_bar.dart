import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';

class MealBreakdownBar extends StatelessWidget {
  const MealBreakdownBar({required this.entries, super.key});

  final List<FoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final perSlot = <MealSlot, double>{
      for (final s in MealSlot.values) s: 0,
    };
    for (final e in entries) {
      perSlot[e.mealSlot] = (perSlot[e.mealSlot] ?? 0) + e.totals.kcal;
    }
    final total = perSlot.values.fold<double>(0, (s, v) => s + v);

    return Container(
      padding: EdgeInsets.fromLTRB(
        spacing.stackLg,
        spacing.stackMd,
        spacing.stackLg,
        spacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                size: 18,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'CALORIES BY MEAL',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackMd),
          _StackedBar(perSlot: perSlot, total: total),
          SizedBox(height: spacing.stackMd),
          Row(
            children: [
              for (var i = 0; i < MealSlot.values.length; i++) ...[
                Expanded(
                  child: _SlotTile(
                    slot: MealSlot.values[i],
                    kcal: perSlot[MealSlot.values[i]] ?? 0,
                    color: _slotColor(context, MealSlot.values[i]),
                  ),
                ),
                if (i < MealSlot.values.length - 1)
                  SizedBox(width: spacing.stackSm),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Color _slotColor(BuildContext context, MealSlot slot) {
    final colors = context.colors;
    return switch (slot) {
      MealSlot.breakfast => colors.chartProtein,
      MealSlot.lunch => colors.chartCarbs,
      MealSlot.dinner => colors.chartFat,
      MealSlot.snack => colors.chartSnack,
    };
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.perSlot, required this.total});

  final Map<MealSlot, double> perSlot;
  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    if (total <= 0) {
      return ClipRRect(
        borderRadius: radius.pill,
        child: Container(
          height: 10,
          color: colors.surfaceContainerHigh,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius.pill,
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (var i = 0; i < MealSlot.values.length; i++)
              if ((perSlot[MealSlot.values[i]] ?? 0) > 0)
                Expanded(
                  flex: ((perSlot[MealSlot.values[i]] ?? 0) * 1000)
                      .round()
                      .clamp(1, 1000000),
                  child: _segment(
                    context,
                    color: MealBreakdownBar._slotColor(
                      context,
                      MealSlot.values[i],
                    ),
                    isFirst: _isFirstNonZero(i),
                    isLast: _isLastNonZero(i),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required Color color,
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(color: context.colors.surface, width: 1.5),
        ),
      ),
    );
  }

  bool _isFirstNonZero(int idx) {
    for (var i = 0; i < idx; i++) {
      if ((perSlot[MealSlot.values[i]] ?? 0) > 0) return false;
    }
    return true;
  }

  bool _isLastNonZero(int idx) {
    for (var i = idx + 1; i < MealSlot.values.length; i++) {
      if ((perSlot[MealSlot.values[i]] ?? 0) > 0) return false;
    }
    return true;
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.kcal,
    required this.color,
  });

  final MealSlot slot;
  final double kcal;
  final Color color;

  IconData get _icon => switch (slot) {
        MealSlot.breakfast => Icons.wb_sunny_outlined,
        MealSlot.lunch => Icons.lunch_dining_outlined,
        MealSlot.dinner => Icons.dinner_dining_outlined,
        MealSlot.snack => Icons.cookie_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final isEmpty = kcal <= 0;
    final tint = isEmpty ? colors.onSurfaceVariant : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_icon, size: 14, color: tint),
            SizedBox(width: spacing.stackSm / 2),
            Expanded(
              child: Text(
                slot.label,
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackSm / 2),
        Text(
          isEmpty ? '—' : kcal.round().toString(),
          style: typography.titleMd.copyWith(color: tint),
        ),
      ],
    );
  }
}
