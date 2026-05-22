import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/di/providers.dart';

// Inferred Riverpod family type is intentionally implicit here.
// ignore: specify_nonobvious_property_types
final activityStreamsProvider =
    FutureProvider.family<ActivityStreams?, String>((ref, activityId) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  final result = await repo.getStreams(activityId);
  return result.fold(
    ok: (streams) => streams,
    err: (_) => null,
  );
});
