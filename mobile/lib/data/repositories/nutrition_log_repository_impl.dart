import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/daily_nutrition_goal.dart';
import 'package:health_app/data/models/food_entry.dart';
import 'package:health_app/data/sources/nutrition_log/nutrition_log_source.dart';
import 'package:health_app/domain/repositories/nutrition_log_repository.dart';

class NutritionLogRepositoryImpl implements NutritionLogRepository {
  NutritionLogRepositoryImpl(this._source);

  final NutritionLogSource _source;

  @override
  Future<Result<List<FoodEntry>>> listEntriesForDate(DateTime date) async {
    try {
      return Result.ok(await _source.listEntriesForDate(date));
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<FoodEntry>> addEntry(FoodEntry entry) async {
    try {
      return Result.ok(await _source.addEntry(entry));
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<void>> removeEntry(String id) async {
    try {
      await _source.removeEntry(id);
      return const Result.ok(null);
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<DailyNutritionGoal>> getDailyGoal() async {
    try {
      return Result.ok(await _source.getDailyGoal());
    } on Object catch (e) {
      return Result.err(UnknownFailure(e.toString(), e));
    }
  }
}
