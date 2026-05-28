import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/features/nutrition/presentation/widgets/edit_entry_sheet.dart';
import 'package:intl/intl.dart';

class LoggedFoodList extends ConsumerWidget {
  const LoggedFoodList({
    required this.entries,
    required this.allowEdit,
    super.key,
  });

  final List<FoodEntry> entries;
  final bool allowEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    if (entries.isEmpty) return _EmptyState(allowEdit: allowEdit);

    final sorted = [...entries]
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: spacing.stackSm / 2),
        itemCount: sorted.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 1,
          color: colors.outlineVariant.withValues(alpha: 0.25),
          indent: spacing.stackLg,
          endIndent: spacing.stackLg,
        ),
        itemBuilder: (_, i) => _EntryTile(
          entry: sorted[i],
          allowEdit: allowEdit,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.allowEdit});

  final bool allowEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.stackLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_outlined, color: colors.onSurfaceVariant),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Text(
              allowEdit
                  ? 'Nothing logged yet.\nTap "Log food" to start.'
                  : 'No food logged on this day.',
              style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry, required this.allowEdit});

  final FoodEntry entry;
  final bool allowEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final totals = entry.totals;
    final time = DateFormat('HH:mm').format(entry.loggedAt.toLocal());
    final amount =
        '${entry.grams.round()} ${entry.foodSnapshot.amountUnit}';

    return InkWell(
      onTap: () => showEntryDetailsSheet(
        context,
        entry: entry,
        allowEdit: allowEdit,
      ),
      onLongPress: allowEdit ? () => _handleDelete(context, ref) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.stackLg,
          vertical: spacing.stackMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MealSlotIcon(slot: entry.mealSlot),
            SizedBox(width: spacing.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodSnapshot.name,
                    style: typography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.stackSm / 4),
                  Text(
                    '$time · $amount',
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.stackSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totals.kcal.round()}',
                  style: typography.titleMd.copyWith(
                    color: colors.enduranceCyan,
                  ),
                ),
                Text(
                  'kcal',
                  style: typography.labelMd.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text(
          'Remove "${entry.foodSnapshot.name}" from today\'s log?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: ctx.colors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final failure = await ref
        .read(dailyNutritionControllerProvider.notifier)
        .removeEntry(entry.id);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }
}

class _MealSlotIcon extends StatelessWidget {
  const _MealSlotIcon({required this.slot});

  final MealSlot slot;

  IconData get _icon => switch (slot) {
        MealSlot.breakfast => Icons.wb_sunny_outlined,
        MealSlot.lunch => Icons.lunch_dining_outlined,
        MealSlot.dinner => Icons.dinner_dining_outlined,
        MealSlot.snack => Icons.cookie_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Icon(_icon, size: 18, color: colors.enduranceCyan),
    );
  }
}
