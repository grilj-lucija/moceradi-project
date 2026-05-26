import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/weight_entry.dart';
import 'package:health_app/data/sources/weights/weight_source.dart';
import 'package:health_app/domain/repositories/weight_repository.dart';

class WeightRepositoryImpl implements WeightRepository {
  WeightRepositoryImpl(this._source);

  final WeightSource _source;

  @override
  DateTime currentWeekStart() => startOfIsoWeek(DateTime.now());

  @override
  Future<Result<WeightEntry?>> getCurrentWeekEntry() async {
    try {
      final entry = await _source.getForWeek(currentWeekStart());
      return Result.ok(entry);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<WeightEntry>> logCurrentWeek(double weightKg) async {
    try {
      final entry = await _source.upsertForWeek(
        weekStart: currentWeekStart(),
        weightKg: weightKg,
      );
      return Result.ok(entry);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  static DateTime startOfIsoWeek(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: now.weekday - 1));
  }
}
