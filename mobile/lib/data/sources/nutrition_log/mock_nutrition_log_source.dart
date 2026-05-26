import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/sources/nutrition_log/nutrition_log_source.dart';

class MockNutritionLogSource implements NutritionLogSource {
  MockNutritionLogSource() {
    _seedToday();
  }

  final Map<String, List<FoodEntry>> _entriesByDate = {};

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _seedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final key = _dateKey(today);

    const oats = Food(
      id: 'seed:oats',
      name: 'Rolled Oats',
      source: FoodSourceKind.custom,
      facts: NutritionFacts(
        kcalPer100g: 379,
        proteinPer100g: 13,
        carbsPer100g: 68,
        fatPer100g: 7,
        sugarPer100g: 1,
      ),
      defaultServingGrams: 60,
    );

    const banana = Food(
      id: 'seed:banana',
      name: 'Banana',
      source: FoodSourceKind.custom,
      facts: NutritionFacts(
        kcalPer100g: 89,
        proteinPer100g: 1.1,
        carbsPer100g: 23,
        fatPer100g: 0.3,
        sugarPer100g: 12,
      ),
      defaultServingGrams: 120,
    );

    const water = Food(
      id: 'seed:water',
      name: 'Water',
      source: FoodSourceKind.custom,
      isBeverage: true,
      facts: NutritionFacts.zero,
      defaultServingGrams: 500,
    );

    _entriesByDate[key] = [
      FoodEntry(
        id: 'seed-e1',
        foodSnapshot: oats,
        grams: 60,
        loggedAt: today.add(const Duration(hours: 7, minutes: 30)),
        mealSlot: MealSlot.breakfast,
      ),
      FoodEntry(
        id: 'seed-e2',
        foodSnapshot: banana,
        grams: 120,
        loggedAt: today.add(const Duration(hours: 10)),
        mealSlot: MealSlot.snack,
      ),
      FoodEntry(
        id: 'seed-e3',
        foodSnapshot: water,
        grams: 500,
        loggedAt: today.add(const Duration(hours: 8)),
        mealSlot: MealSlot.breakfast,
      ),
    ];
  }

  @override
  Future<List<FoodEntry>> listEntriesForDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final normalized = DateTime(date.year, date.month, date.day);
    return List.unmodifiable(_entriesByDate[_dateKey(normalized)] ?? const []);
  }

  @override
  Future<FoodEntry> addEntry(FoodEntry entry) async {
    final normalized = DateTime(
      entry.loggedAt.year,
      entry.loggedAt.month,
      entry.loggedAt.day,
    );
    final key = _dateKey(normalized);
    _entriesByDate.putIfAbsent(key, () => <FoodEntry>[])
      ..add(entry)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return entry;
  }

  @override
  Future<FoodEntry> updateEntry(
    String id, {
    double? grams,
    MealSlot? mealSlot,
  }) async {
    for (final list in _entriesByDate.values) {
      final i = list.indexWhere((e) => e.id == id);
      if (i == -1) continue;
      final current = list[i];
      final updated = FoodEntry(
        id: current.id,
        foodSnapshot: current.foodSnapshot,
        grams: grams ?? current.grams,
        loggedAt: current.loggedAt,
        mealSlot: mealSlot ?? current.mealSlot,
      );
      list[i] = updated;
      return updated;
    }
    throw StateError('Entry not found: $id');
  }

  @override
  Future<void> removeEntry(String id) async {
    for (final list in _entriesByDate.values) {
      list.removeWhere((e) => e.id == id);
    }
  }

  DailyNutritionGoal _goal = kDefaultDailyGoal;

  @override
  Future<DailyNutritionGoal> getDailyGoal() async => _goal;

  @override
  Future<DailyNutritionGoal> updateDailyKcal(double kcal) async {
    return _goal = DailyNutritionGoal(
      kcal: kcal,
      proteinGrams: _goal.proteinGrams,
      carbsGrams: _goal.carbsGrams,
      fatGrams: _goal.fatGrams,
      sugarGrams: _goal.sugarGrams,
      liquidsMl: _goal.liquidsMl,
    );
  }
}
