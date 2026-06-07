import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/weight_entry.dart';

abstract interface class WeightRepository {
  Future<Result<WeightEntry?>> getCurrentWeekEntry();

  Future<Result<WeightEntry>> logCurrentWeek(double weightKg);

  DateTime currentWeekStart();
}
