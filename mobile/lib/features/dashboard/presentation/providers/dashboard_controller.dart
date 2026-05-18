import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/di/providers.dart';

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}

final recentActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  final result = await repo.listRecent();
  return result.fold(
    ok: (items) => items,
    err: (failure) => throw _FailureException(failure),
  );
});
