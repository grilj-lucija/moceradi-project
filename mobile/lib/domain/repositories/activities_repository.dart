import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/activity.dart';

abstract interface class ActivitiesRepository {
  Future<Result<List<Activity>>> listRecent({int limit = 20});

  Future<Result<Activity>> getById(String id);
}
