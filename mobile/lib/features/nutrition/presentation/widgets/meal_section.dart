import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';

class MealSection extends StatelessWidget {
  const MealSection({
    required this.slot,
    required this.entries,
    required this.onRemove,
    super.key,
  });

  final MealSlot slot;
  final List<FoodEntry> entries;
  final void Function(FoodEntry entry) onRemove;

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
    final radius = context.radius;
    final spacing = context.spacing;

    final totalKcal = entries.fold<double>(0, (sum, e) => sum + e.totals.kcal);

    return Container(
      padding: EdgeInsets.all(spacing.stackMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: colors.enduranceCyan, size: 20),
              SizedBox(width: spacing.stackSm),
              Expanded(
                child: Text(slot.label, style: typography.titleMd),
              ),
              Text(
                '${totalKcal.round()} kcal',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (entries.isEmpty) ...[
            SizedBox(height: spacing.stackSm),
            Text(
              'Nothing logged yet.',
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            SizedBox(height: spacing.stackSm),
            for (final entry in entries) ...[
              _EntryRow(entry: entry, onRemove: () => onRemove(entry)),
              if (entry != entries.last)
                Divider(color: colors.outlineVariant, height: 16),
            ],
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onRemove});

  final FoodEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final totals = entry.totals;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.foodSnapshot.name,
                style: typography.bodyLg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.grams.round()}${entry.foodSnapshot.amountUnit} • '
                'P ${totals.proteinGrams.round()}g · '
                'C ${totals.carbsGrams.round()}g · '
                'F ${totals.fatGrams.round()}g · '
                'S ${totals.sugarGrams.round()}g',
                style: typography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.stackSm),
        Text(
          '${totals.kcal.round()}',
          style: typography.titleMd.copyWith(color: colors.enduranceCyan),
        ),
        IconButton(
          onPressed: onRemove,
          icon: Icon(Icons.close, color: colors.onSurfaceVariant, size: 18),
          tooltip: 'Remove',
        ),
      ],
    );
  }
}
