import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/result/result.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:health_app/domain/repositories/activities_repository.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  ActivitiesRepositoryImpl(this._source);

  final ActivitiesSource _source;

  @override
  Future<Result<List<Activity>>> listRecent({int limit = 20}) async {
    try {
      final items = await _source.listRecent(limit: limit);
      return Result.ok(items);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<Activity>> getById(String id) async {
    try {
      final item = await _source.getById(id);
      if (item == null) {
        return const Result.err(NotFoundFailure('Activity not found'));
      }
      return Result.ok(item);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<ActivityStreams?>> getStreams(String id) async {
    try {
      final streams = await _source.getStreams(id);
      return Result.ok(streams);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }

  @override
  Future<Result<Activity>> save(WorkoutSession session, {String? title}) async {
    try {
      final saved = await _source.save(session, title: title);
      return Result.ok(saved);
    } on Object catch (e) {
      return Result.err(NetworkFailure(e.toString(), e));
    }
  }
}
