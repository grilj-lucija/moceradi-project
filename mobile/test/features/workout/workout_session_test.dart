import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';

WorkoutPoint _point(
  double lat,
  double lng, {
  double? altitude,
  double? speedMps,
}) {
  return WorkoutPoint(
    t: DateTime.utc(2024, 1, 1, 12),
    lat: lat,
    lng: lng,
    altitude: altitude,
    speedMps: speedMps,
  );
}

WorkoutSession _session({
  ActivityType type = ActivityType.walking,
  double weightKg = 70,
  int durationSeconds = 0,
  List<WorkoutPoint> points = const [],
}) {
  final start = DateTime.utc(2024, 1, 1, 12);
  return WorkoutSession(
    type: type,
    startedAt: start,
    durationSeconds: durationSeconds,
    points: points,
    isPaused: false,
    weightKg: weightKg,
    laps: const [],
    currentLapStartedAt: start,
    currentLapStartDuration: 0,
    currentLapStartDistance: 0,
  );
}

void main() {
  group('caloriesKcal', () {
    test('is zero when no time has elapsed', () {
      expect(_session().caloriesKcal, 0);
    });

    test('uses MET formula for walking', () {
      final session = _session(durationSeconds: 3600);
      expect(session.caloriesKcal, closeTo(245, 0.001));
    });

    test('scales with MET, weight and duration for running', () {
      final session = _session(
        type: ActivityType.running,
        weightKg: 80,
        durationSeconds: 1800,
      );
      expect(session.caloriesKcal, closeTo(392, 0.001));
    });
  });

  group('distanceMeters', () {
    test('is zero with fewer than two points', () {
      expect(_session().distanceMeters, 0);
      expect(_session(points: [_point(0, 0)]).distanceMeters, 0);
    });

    test('computes haversine distance between two points', () {
      final session = _session(points: [_point(0, 0), _point(0, 0.001)]);
      expect(session.distanceMeters, closeTo(111.19, 1));
    });

    test('accumulates distance across multiple segments', () {
      final session = _session(
        points: [_point(0, 0), _point(0, 0.001), _point(0, 0.002)],
      );
      expect(session.distanceMeters, closeTo(222.39, 2));
    });
  });

  group('elevationGainMeters', () {
    test('sums only positive altitude deltas', () {
      final session = _session(
        points: [
          _point(0, 0, altitude: 100),
          _point(0, 0.0001, altitude: 110),
          _point(0, 0.0002, altitude: 105),
          _point(0, 0.0003, altitude: 120),
        ],
      );
      expect(session.elevationGainMeters, closeTo(25, 0.001));
    });

    test('ignores points without altitude data', () {
      final session = _session(
        points: [_point(0, 0), _point(0, 0.0001)],
      );
      expect(session.elevationGainMeters, 0);
    });
  });

  group('currentSpeedMps', () {
    test('is zero with no points', () {
      expect(_session().currentSpeedMps, 0);
    });

    test('uses the reported speed of the last point when available', () {
      final session = _session(points: [_point(0, 0, speedMps: 4.2)]);
      expect(session.currentSpeedMps, 4.2);
    });
  });

  group('avgSpeedMps', () {
    test('is zero without duration', () {
      final session = _session(points: [_point(0, 0), _point(0, 0.001)]);
      expect(session.avgSpeedMps, 0);
    });

    test('is distance over duration', () {
      final session = _session(
        durationSeconds: 100,
        points: [_point(0, 0), _point(0, 0.001)],
      );
      expect(session.avgSpeedMps, closeTo(111.19 / 100, 0.05));
    });
  });

  group('lap getters', () {
    test('subtract lap start offsets from totals', () {
      final session = _session(
        durationSeconds: 300,
        points: [_point(0, 0), _point(0, 0.002)],
      ).copyWith(currentLapStartDuration: 120, currentLapStartDistance: 50);

      expect(session.currentLapDurationSeconds, 180);
      expect(
        session.currentLapDistanceMeters,
        closeTo(session.distanceMeters - 50, 0.001),
      );
    });

    test('clamp negative lap values to zero', () {
      final session = _session(durationSeconds: 10)
          .copyWith(currentLapStartDuration: 100, currentLapStartDistance: 9999);

      expect(session.currentLapDurationSeconds, 0);
      expect(session.currentLapDistanceMeters, 0);
    });
  });

  group('ActivityType wire mapping', () {
    test('round trips through its wire value', () {
      for (final type in ActivityType.values) {
        expect(ActivityTypeX.fromWire(type.wire), type);
      }
    });

    test('falls back to walking for an unknown value', () {
      expect(ActivityTypeX.fromWire('parachuting'), ActivityType.walking);
    });
  });
}
