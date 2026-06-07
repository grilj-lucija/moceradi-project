import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/data/models/weight_entry.dart';
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}

final currentWeekWeightProvider = FutureProvider<WeightEntry?>((ref) async {
  final repo = ref.watch(weightRepositoryProvider);
  final result = await repo.getCurrentWeekEntry();
  return result.fold(
    ok: (entry) => entry,
    err: (failure) => throw _FailureException(failure),
  );
});

class WeightController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> log(double kg) async {
    state = const AsyncLoading();
    final result = await ref.read(weightRepositoryProvider).logCurrentWeek(kg);
    return result.fold(
      ok: (_) {
        state = const AsyncData(null);
        ref
          ..invalidate(currentWeekWeightProvider)
          ..invalidate(currentProfileProvider);
        return null;
      },
      err: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
    );
  }
}

final weightControllerProvider =
    AsyncNotifierProvider<WeightController, void>(WeightController.new);
