import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/di/providers.dart';

class DailyNutritionState extends Equatable {
  const DailyNutritionState({
    required this.date,
    required this.goal,
    required this.entries,
  });

  final DateTime date;
  final DailyNutritionGoal goal;
  final List<FoodEntry> entries;

  NutritionTotals get totals => entries.fold(
        NutritionTotals.zero,
        (sum, e) => sum + e.totals,
      );

  double get liquidsMl => entries
      .where((e) => e.foodSnapshot.isBeverage)
      .fold(0, (sum, e) => sum + e.grams);

  Map<MealSlot, List<FoodEntry>> get entriesByMeal {
    final byMeal = {for (final slot in MealSlot.values) slot: <FoodEntry>[]};
    for (final entry in entries) {
      byMeal[entry.mealSlot]!.add(entry);
    }
    return byMeal;
  }

  @override
  List<Object?> get props => [date, goal, entries];
}

class DailyNutritionController extends AsyncNotifier<DailyNutritionState> {
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<DailyNutritionState> build() async {
    final today = _normalize(DateTime.now());
    return _load(today);
  }

  Future<DailyNutritionState> _load(DateTime date) async {
    final repo = ref.read(nutritionLogRepositoryProvider);
    final goalResult = await repo.getDailyGoal();
    final entriesResult = await repo.listEntriesForDate(date);
    final goal = goalResult.fold(
      ok: (g) => g,
      err: (_) => kDefaultDailyGoal,
    );
    return DailyNutritionState(
      date: date,
      goal: goal,
      entries: entriesResult.fold(
        ok: (e) => e,
        err: (_) => const [],
      ),
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    final date = current?.date ?? _normalize(DateTime.now());
    state = const AsyncLoading();
    try {
      state = AsyncData(await _load(date));
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setDate(DateTime date) async {
    final normalized = _normalize(date);
    final current = state.value;
    if (current != null && current.date == normalized) return;
    state = const AsyncLoading();
    try {
      state = AsyncData(await _load(normalized));
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<Failure?> addEntry(FoodEntry entry) async {
    final result = await ref.read(nutritionLogRepositoryProvider).addEntry(entry);
    return result.fold(
      ok: (_) async {
        await refresh();
        return null;
      },
      err: (failure) => failure,
    );
  }

  Future<Failure?> removeEntry(String id) async {
    final result =
        await ref.read(nutritionLogRepositoryProvider).removeEntry(id);
    return result.fold(
      ok: (_) async {
        await refresh();
        return null;
      },
      err: (failure) => failure,
    );
  }
}

final dailyNutritionControllerProvider =
    AsyncNotifierProvider<DailyNutritionController, DailyNutritionState>(
  DailyNutritionController.new,
);
