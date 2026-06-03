import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/models/meal_slot.dart';

abstract interface class NutritionLogRepository {
  Future<Result<List<FoodEntry>>> listEntriesForDate(DateTime date);

  Future<Result<FoodEntry>> addEntry(FoodEntry entry);

  Future<Result<FoodEntry>> updateEntry(
    String id, {
    double? grams,
    MealSlot? mealSlot,
  });

  Future<Result<void>> removeEntry(String id);

  Future<Result<DailyNutritionGoal>> getDailyGoal();

  Future<Result<DailyNutritionGoal>> updateDailyKcal(double kcal);
}
