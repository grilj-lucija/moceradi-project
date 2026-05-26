import 'package:health_app/data/models/weight_entry.dart';

abstract interface class WeightSource {
  Future<WeightEntry?> getForWeek(DateTime weekStart);

  Future<WeightEntry> upsertForWeek({
    required DateTime weekStart,
    required double weightKg,
  });
}
