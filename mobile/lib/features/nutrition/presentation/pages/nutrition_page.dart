import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/features/nutrition/presentation/widgets/calorie_ring.dart';
import 'package:health_app/features/nutrition/presentation/widgets/liquids_card.dart';
import 'package:health_app/features/nutrition/presentation/widgets/macro_bar.dart';
import 'package:health_app/features/nutrition/presentation/widgets/meal_section.dart';
import 'package:health_app/shared/widgets/buttons/floating_action_pill.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/layout/page_header.dart';
import 'package:intl/intl.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final state = ref.watch(dailyNutritionControllerProvider);
    final notifier = ref.read(dailyNutritionControllerProvider.notifier);

    final selectedDate = state.value?.date ?? _today();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              spacing.containerMarginMobile,
              spacing.stackLg,
              spacing.containerMarginMobile,
              FloatingActionPill.reservedListPadding(context),
            ),
            children: [
              PageHeader(
                eyebrow: _eyebrowFor(selectedDate),
                title: 'Nutrition',
                trailing: _DatePickerButton(
                  selectedDate: selectedDate,
                  onPick: notifier.setDate,
                ),
              ),
              SizedBox(height: spacing.stackMd),
              state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Could not load nutrition: $e',
                  style: typography.bodyMd.copyWith(color: colors.error),
                ),
                data: (data) {
                  final totals = data.totals;
                  final byMeal = data.entriesByMeal;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassCard(
                        child: Center(
                          child: CalorieRing(
                            consumedKcal: totals.kcal,
                            goalKcal: data.goal.kcal,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.stackMd),
                      MacroBar(
                        proteinGrams: totals.proteinGrams,
                        carbsGrams: totals.carbsGrams,
                        fatGrams: totals.fatGrams,
                        proteinGoalGrams: data.goal.proteinGrams,
                        carbsGoalGrams: data.goal.carbsGrams,
                        fatGoalGrams: data.goal.fatGrams,
                      ),
                      SizedBox(height: spacing.stackMd),
                      LiquidsCard(
                        consumedMl: data.liquidsMl,
                        goalMl: data.goal.liquidsMl,
                      ),
                      SizedBox(height: spacing.stackLg),
                      for (var i = 0; i < MealSlot.values.length; i++) ...[
                        MealSection(
                          slot: MealSlot.values[i],
                          entries: byMeal[MealSlot.values[i]] ?? const [],
                          onRemove: (entry) async {
                            await notifier.removeEntry(entry.id);
                          },
                        ),
                        if (i < MealSlot.values.length - 1)
                          SizedBox(height: spacing.stackMd),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        FloatingActionPill(
          label: 'Log food',
          icon: Icons.add,
          onPressed: () => context.push(AppRoutes.nutritionAdd),
        ),
      ],
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _eyebrowFor(DateTime date) {
    final today = _today();
    final diff = date.difference(today).inDays;
    if (diff == 0) return 'Today · ${DateFormat('MMM d').format(date)}';
    if (diff == -1) return 'Yesterday · ${DateFormat('MMM d').format(date)}';
    return DateFormat('EEE · MMM d').format(date);
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.selectedDate,
    required this.onPick,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final today = NutritionPage._today();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
    final tooltip = isToday
        ? 'Pick a date'
        : 'Viewing ${DateFormat('MMM d').format(selectedDate)}';

    return IconButton(
      tooltip: tooltip,
      onPressed: () => _open(context),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: colors.onSurfaceVariant,
          ),
          if (!isToday)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: colors.enduranceCyan,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final colors = context.colors;
    final today = NutritionPage._today();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: colors.enduranceCyan,
                  onPrimary: colors.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPick(picked);
  }
}
