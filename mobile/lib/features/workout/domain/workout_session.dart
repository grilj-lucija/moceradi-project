import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:health_app/data/models/activity.dart';
export 'package:health_app/data/models/activity.dart' show ActivityType, ActivityTypeX;

class WorkoutPoint extends Equatable {
  const WorkoutPoint({
    required this.t,
    required this.lat,
    required this.lng,
    this.altitude,
    this.speedMps,
  });

  final DateTime t;
  final double lat;
  final double lng;
  final double? altitude;
  final double? speedMps;

  @override
  List<Object?> get props => [t, lat, lng, altitude, speedMps];
}

class WorkoutLap extends Equatable {
  const WorkoutLap({
    required this.index,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.distanceMeters,
  });

  final int index;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final double distanceMeters;

  Duration get duration => Duration(seconds: durationSeconds);

  double get avgSpeedMps {
    if (durationSeconds <= 0) return 0;
    return distanceMeters / durationSeconds;
  }

  @override
  List<Object?> get props =>
      [index, startedAt, endedAt, durationSeconds, distanceMeters];
}

class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.type,
    required this.startedAt,
    required this.durationSeconds,
    required this.points,
    required this.isPaused,
    required this.weightKg,
    required this.laps,
    required this.currentLapStartedAt,
    required this.currentLapStartDuration,
    required this.currentLapStartDistance,
    this.endedAt,
  });

  factory WorkoutSession.initial({
    required ActivityType type,
    required double weightKg,
    DateTime? startedAt,
  }) {
    final start = startedAt ?? DateTime.now();
    return WorkoutSession(
      type: type,
      startedAt: start,
      durationSeconds: 0,
      points: const [],
      isPaused: false,
      weightKg: weightKg,
      laps: const [],
      currentLapStartedAt: start,
      currentLapStartDuration: 0,
      currentLapStartDistance: 0,
    );
  }

  final ActivityType type;
  final DateTime startedAt;
  final int durationSeconds;
  final List<WorkoutPoint> points;
  final bool isPaused;
  final double weightKg;
  final List<WorkoutLap> laps;
  final DateTime currentLapStartedAt;
  final int currentLapStartDuration;
  final double currentLapStartDistance;
  final DateTime? endedAt;

  Duration get duration => Duration(seconds: durationSeconds);

  int get currentLapIndex => laps.length + 1;

  double get currentLapDistanceMeters =>
      (distanceMeters - currentLapStartDistance).clamp(0, double.infinity);

  int get currentLapDurationSeconds =>
      (durationSeconds - currentLapStartDuration).clamp(0, 1 << 30);

  Duration get currentLapDuration =>
      Duration(seconds: currentLapDurationSeconds);

  double get currentLapAvgSpeedMps {
    if (currentLapDurationSeconds <= 0) return 0;
    return currentLapDistanceMeters / currentLapDurationSeconds;
  }

  double get distanceMeters {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _haversine(points[i - 1], points[i]);
    }
    return total;
  }

  double get distanceKm => distanceMeters / 1000.0;

  double get elevationGainMeters {
    if (points.length < 2) return 0;
    var gain = 0.0;
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1].altitude;
      final curr = points[i].altitude;
      if (prev == null || curr == null) continue;
      final delta = curr - prev;
      if (delta > 0) gain += delta;
    }
    return gain;
  }

  double get currentSpeedMps {
    if (points.isEmpty) return 0;
    final last = points.last.speedMps;
    if (last != null && last >= 0) return last;
    if (points.length < 2) return 0;
    final p1 = points[points.length - 2];
    final p2 = points.last;
    final d = _haversine(p1, p2);
    final dt = p2.t.difference(p1.t).inMilliseconds / 1000.0;
    if (dt <= 0) return 0;
    return d / dt;
  }

  double get avgSpeedMps {
    if (durationSeconds <= 0) return 0;
    return distanceMeters / durationSeconds;
  }

  double get caloriesKcal {
    if (durationSeconds <= 0) return 0;
    return type.metValue * weightKg * durationSeconds / 3600.0;
  }

  WorkoutSession copyWith({
    int? durationSeconds,
    List<WorkoutPoint>? points,
    bool? isPaused,
    double? weightKg,
    DateTime? endedAt,
    List<WorkoutLap>? laps,
    DateTime? currentLapStartedAt,
    int? currentLapStartDuration,
    double? currentLapStartDistance,
  }) =>
      WorkoutSession(
        type: type,
        startedAt: startedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        points: points ?? this.points,
        isPaused: isPaused ?? this.isPaused,
        weightKg: weightKg ?? this.weightKg,
        endedAt: endedAt ?? this.endedAt,
        laps: laps ?? this.laps,
        currentLapStartedAt: currentLapStartedAt ?? this.currentLapStartedAt,
        currentLapStartDuration:
            currentLapStartDuration ?? this.currentLapStartDuration,
        currentLapStartDistance:
            currentLapStartDistance ?? this.currentLapStartDistance,
      );

  @override
  List<Object?> get props => [
        type,
        startedAt,
        durationSeconds,
        points,
        isPaused,
        weightKg,
        endedAt,
        laps,
        currentLapStartedAt,
        currentLapStartDuration,
        currentLapStartDistance,
      ];
}

double _haversine(WorkoutPoint a, WorkoutPoint b) {
  const r = 6371000.0;
  final lat1 = a.lat * math.pi / 180;
  final lat2 = b.lat * math.pi / 180;
  final dLat = (b.lat - a.lat) * math.pi / 180;
  final dLng = (b.lng - a.lng) * math.pi / 180;
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return r * c;
}
