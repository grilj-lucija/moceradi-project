import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';

abstract interface class ActivitiesRepository {
  Future<Result<List<Activity>>> listRecent({int limit = 20});

  Future<Result<Activity>> getById(String id);

  Future<Result<ActivityStreams?>> getStreams(String id);

  Future<Result<Activity>> save(WorkoutSession session, {String? title});
}
