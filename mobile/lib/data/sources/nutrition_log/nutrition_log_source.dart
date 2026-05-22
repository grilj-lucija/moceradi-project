import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';

abstract interface class NutritionLogSource {
  Future<List<FoodEntry>> listEntriesForDate(DateTime date);

  Future<FoodEntry> addEntry(FoodEntry entry);

  Future<void> removeEntry(String id);

  Future<DailyNutritionGoal> getDailyGoal();
}
