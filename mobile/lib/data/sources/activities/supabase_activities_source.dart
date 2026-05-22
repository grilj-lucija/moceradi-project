import 'package:health_app/data/models/activity.dart';
import 'package:health_app/data/sources/activities/activities_source.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:health_app/features/workout/services/polyline_codec.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseActivitiesSource implements ActivitiesSource {
  SupabaseActivitiesSource(this._client);

  final SupabaseClient _client;

  static const _activitiesTable = 'activities';
  static const _streamsTable = 'activity_streams';

  String _requireUid() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Not signed in');
    return uid;
  }

  @override
  Future<List<Activity>> listRecent({int limit = 20}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];
    final rows = await _client
        .from(_activitiesTable)
        .select()
        .eq('user_id', uid)
        .order('started_at', ascending: false)
        .limit(limit);
    return [
      for (final row in rows as List<dynamic>)
        Activity.fromJson(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<Activity?> getById(String id) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from(_activitiesTable)
        .select()
        .eq('id', id)
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return Activity.fromJson(row);
  }

  @override
  Future<ActivityStreams?> getStreams(String id) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final owned = await _client
        .from(_activitiesTable)
        .select('id')
        .eq('id', id)
        .eq('user_id', uid)
        .maybeSingle();
    if (owned == null) return null;
    final row = await _client
        .from(_streamsTable)
        .select()
        .eq('activity_id', id)
        .maybeSingle();
    if (row == null) return null;
    return ActivityStreams.fromJson({...row, 'activity_id': id});
  }

  @override
  Future<Activity> save(WorkoutSession session, {String? title}) async {
    final uid = _requireUid();
    final endedAt = session.endedAt ?? DateTime.now();

    final points = session.points;
    final distance = session.distanceMeters;
    final avgPaceSecPerKm = distance > 0
        ? session.durationSeconds / (distance / 1000.0)
        : null;
    final maxSpeed = _computeMaxSpeed(session);
    final summaryPolyline = points.isEmpty
        ? null
        : encodePolyline(
            downsamplePoints(points)
                .map((p) => LatLng(p.lat, p.lng)),
          );
    final bounds = _computeBounds(points);

    final activityPayload = <String, dynamic>{
      'user_id': uid,
      'type': session.type.wire,
      'title': title,
      'started_at': session.startedAt.toUtc().toIso8601String(),
      'ended_at': endedAt.toUtc().toIso8601String(),
      'duration_seconds': session.durationSeconds,
      'moving_seconds': session.durationSeconds,
      'distance_meters': distance,
      'elevation_gain_meters': session.elevationGainMeters,
      'avg_pace_s_per_km': avgPaceSecPerKm,
      'max_speed_mps': maxSpeed,
      'calories_kcal': session.caloriesKcal,
      'weight_kg': session.weightKg,
      'start_lat': points.isNotEmpty ? points.first.lat : null,
      'start_lng': points.isNotEmpty ? points.first.lng : null,
      'end_lat': points.isNotEmpty ? points.last.lat : null,
      'end_lng': points.isNotEmpty ? points.last.lng : null,
      'bounds': bounds?.toJson(),
      'summary_polyline': summaryPolyline,
      'laps': [
        for (final lap in session.laps)
          {
            'index': lap.index,
            'started_at': lap.startedAt.toUtc().toIso8601String(),
            'ended_at': lap.endedAt.toUtc().toIso8601String(),
            'duration_seconds': lap.durationSeconds,
            'distance_meters': lap.distanceMeters,
          },
      ],
      'source': 'workout',
    };

    final inserted = await _client
        .from(_activitiesTable)
        .insert(activityPayload)
        .select()
        .single();

    final activityId = inserted['id'] as String;

    if (points.isNotEmpty) {
      final t0 = session.startedAt.millisecondsSinceEpoch;
      await _client.from(_streamsTable).insert({
        'activity_id': activityId,
        'time_offsets_ms': [
          for (final p in points) p.t.millisecondsSinceEpoch - t0,
        ],
        'lats': [for (final p in points) p.lat],
        'lngs': [for (final p in points) p.lng],
        'altitudes': [for (final p in points) p.altitude],
        'speeds_mps': [for (final p in points) p.speedMps],
      });
    }

    return Activity.fromJson(inserted);
  }

  static double? _computeMaxSpeed(WorkoutSession session) {
    double? max;
    for (final p in session.points) {
      final s = p.speedMps;
      if (s == null) continue;
      if (max == null || s > max) max = s;
    }
    return max;
  }

  static ActivityBounds? _computeBounds(List<WorkoutPoint> points) {
    if (points.isEmpty) return null;
    var n = points.first.lat;
    var s = points.first.lat;
    var e = points.first.lng;
    var w = points.first.lng;
    for (final p in points) {
      if (p.lat > n) n = p.lat;
      if (p.lat < s) s = p.lat;
      if (p.lng > e) e = p.lng;
      if (p.lng < w) w = p.lng;
    }
    return ActivityBounds(north: n, south: s, east: e, west: w);
  }
}
