import 'package:health_app/data/models/weight_entry.dart';
import 'package:health_app/data/sources/weights/weight_source.dart';

class MockWeightSource implements WeightSource {
  MockWeightSource();

  final Map<String, WeightEntry> _entries = {};

  static String _key(DateTime weekStart) =>
      '${weekStart.year}-${weekStart.month}-${weekStart.day}';

  @override
  Future<WeightEntry?> getForWeek(DateTime weekStart) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _entries[_key(weekStart)];
  }

  @override
  Future<WeightEntry> upsertForWeek({
    required DateTime weekStart,
    required double weightKg,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final entry = WeightEntry(
      id: 'mock-${_key(weekStart)}',
      weightKg: weightKg,
      loggedAt: DateTime.now(),
      weekStart: weekStart,
    );
    _entries[_key(weekStart)] = entry;
    return entry;
  }
}
