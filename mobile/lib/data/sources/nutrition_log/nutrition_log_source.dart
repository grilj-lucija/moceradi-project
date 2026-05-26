import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';

abstract interface class NutritionLogSource {
  Future<List<FoodEntry>> listEntriesForDate(DateTime date);

  Future<FoodEntry> addEntry(FoodEntry entry);

  Future<FoodEntry> updateEntry(
    String id, {
    double? grams,
    MealSlot? mealSlot,
  });

  Future<void> removeEntry(String id);

  Future<DailyNutritionGoal> getDailyGoal();

  Future<DailyNutritionGoal> updateDailyKcal(double kcal);
}
