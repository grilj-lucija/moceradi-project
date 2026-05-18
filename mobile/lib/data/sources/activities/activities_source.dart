import 'package:health_app/data/models/activity.dart';

abstract interface class ActivitiesSource {
  Future<List<Activity>> listRecent({int limit = 20});

  Future<Activity?> getById(String id);
}
