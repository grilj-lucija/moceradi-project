import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';

abstract interface class ActivitiesSource {
  Future<List<Activity>> listRecent({int limit = 20});

  Future<Activity?> getById(String id);

  Future<ActivityStreams?> getStreams(String id);

  Future<Activity> save(WorkoutSession session, {String? title});
}
