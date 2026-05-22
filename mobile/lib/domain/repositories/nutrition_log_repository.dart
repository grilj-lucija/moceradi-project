import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';

abstract interface class NutritionLogRepository {
  Future<Result<List<FoodEntry>>> listEntriesForDate(DateTime date);

  Future<Result<FoodEntry>> addEntry(FoodEntry entry);

  Future<Result<void>> removeEntry(String id);

  Future<Result<DailyNutritionGoal>> getDailyGoal();
}
