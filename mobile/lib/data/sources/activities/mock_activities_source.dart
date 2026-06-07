import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';

class MockActivitiesSource implements ActivitiesSource {
  static final List<Activity> _activities = [
    Activity(
      id: 'a1',
      title: 'Morning Pivola Loop',
      type: ActivityType.running,
      startedAt: DateTime.now().subtract(const Duration(hours: 4)),
      durationSeconds: 2640,
      distanceMeters: 7820,
      averageHeartRate: 152,
      elevationGainMeters: 142,
    ),
    Activity(
      id: 'a2',
      title: 'Pohorje Climb',
      type: ActivityType.cycling,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      durationSeconds: 7320,
      distanceMeters: 48200,
      averageHeartRate: 138,
      elevationGainMeters: 980,
    ),
    Activity(
      id: 'a3',
      title: 'Recovery Walk Mestni Park',
      type: ActivityType.walking,
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      durationSeconds: 1860,
      distanceMeters: 2310,
      averageHeartRate: 96,
    ),
    Activity(
      id: 'a4',
      title: 'Intervals @ Track',
      type: ActivityType.running,
      startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
      durationSeconds: 3120,
      distanceMeters: 9100,
      averageHeartRate: 168,
      elevationGainMeters: 18,
    ),
    Activity(
      id: 'a5',
      title: 'Drava River Long Ride',
      type: ActivityType.cycling,
      startedAt: DateTime.now().subtract(const Duration(days: 5)),
      durationSeconds: 11400,
      distanceMeters: 86400,
      averageHeartRate: 132,
      elevationGainMeters: 412,
    ),
  ];

  @override
  Future<List<Activity>> listRecent({int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _activities.take(limit).toList();
  }

  @override
  Future<Activity?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final match = _activities.where((a) => a.id == id);
    return match.isEmpty ? null : match.first;
  }

  @override
  Future<ActivityStreams?> getStreams(String id) async => null;

  @override
  Future<Activity> save(WorkoutSession session, {String? title}) async {
    throw UnsupportedError('Mock activities source does not persist workouts');
  }
}
