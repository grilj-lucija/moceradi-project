import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:health_app/di/providers.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum WorkoutStartError { permissionDenied }

class WorkoutController extends Notifier<WorkoutSession?> {
  Timer? _ticker;
  StreamSubscription<Position>? _locSub;
  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  UserAccelerometerEvent? _lastAccel;
  GyroscopeEvent? _lastGyro;

  static const double _defaultWeightKg = 70;

  @override
  WorkoutSession? build() {
    ref.onDispose(_cleanup);
    return null;
  }

  Future<WorkoutStartError?> start(ActivityType type) async {
    final location = ref.read(locationServiceProvider);
    final granted = await location.ensurePermission();
    if (!granted) return WorkoutStartError.permissionDenied;

    final profile = ref.read(currentProfileProvider).value;
    final weightKg = profile?.weightKg ?? _defaultWeightKg;

    state = WorkoutSession.initial(type: type, weightKg: weightKg);

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s == null || s.endedAt != null) return;
      if (s.isPaused) {
        _publishTelemetry(s);
        return;
      }
      final next = s.copyWith(durationSeconds: s.durationSeconds + 1);
      state = next;
      _publishTelemetry(next);
    });

    await _locSub?.cancel();
    _locSub = location.stream().listen(_onPosition);

    await _accelSub?.cancel();
    _accelSub = userAccelerometerEventStream().listen((e) => _lastAccel = e);
    await _gyroSub?.cancel();
    _gyroSub = gyroscopeEventStream().listen((e) => _lastGyro = e);

    return null;
  }

  void _onPosition(Position p) {
    final s = state;
    if (s == null || s.isPaused || s.endedAt != null) return;
    final point = WorkoutPoint(
      t: DateTime.now(),
      lat: p.latitude,
      lng: p.longitude,
      altitude: p.altitude,
      speedMps: p.speed >= 0 ? p.speed : null,
    );
    final next = s.copyWith(points: [...s.points, point]);
    state = next;
    _publishTelemetry(next, point: point);
  }

  void _publishTelemetry(WorkoutSession s, {WorkoutPoint? point, bool ended = false}) {
    final accel = _lastAccel;
    final gyro = _lastGyro;
    ref.read(mqttServiceProvider).publishTelemetry({
      't': (point?.t ?? DateTime.now()).toUtc().toIso8601String(),
      'type': s.type.name,
      'paused': s.isPaused,
      if (ended) 'ended': true,
      if (point != null) 'lat': point.lat,
      if (point != null) 'lng': point.lng,
      if (point != null) 'altitude': point.altitude,
      'speedMps': point?.speedMps ?? s.currentSpeedMps,
      'distanceM': s.distanceMeters,
      'durationS': s.durationSeconds,
      'caloriesKcal': s.caloriesKcal,
      if (accel != null)
        'accel': {'x': accel.x, 'y': accel.y, 'z': accel.z},
      if (gyro != null) 'gyro': {'x': gyro.x, 'y': gyro.y, 'z': gyro.z},
    });
  }

  void pause() {
    final s = state;
    if (s == null || s.endedAt != null) return;
    state = s.copyWith(isPaused: true);
  }

  void resume() {
    final s = state;
    if (s == null || s.endedAt != null) return;
    state = s.copyWith(isPaused: false);
  }

  void markLap() {
    final s = state;
    if (s == null || s.endedAt != null) return;
    final lapDuration = s.currentLapDurationSeconds;
    final lapDistance = s.currentLapDistanceMeters;
    if (lapDuration <= 0 && lapDistance <= 0) return;
    final now = DateTime.now();
    final lap = WorkoutLap(
      index: s.laps.length + 1,
      startedAt: s.currentLapStartedAt,
      endedAt: now,
      durationSeconds: lapDuration,
      distanceMeters: lapDistance,
    );
    state = s.copyWith(
      laps: [...s.laps, lap],
      currentLapStartedAt: now,
      currentLapStartDuration: s.durationSeconds,
      currentLapStartDistance: s.distanceMeters,
    );
  }

  void stop() {
    final s = state;
    if (s == null) return;
    _publishTelemetry(s, ended: true);
    _ticker?.cancel();
    _ticker = null;
    unawaited(_locSub?.cancel());
    _locSub = null;
    unawaited(_accelSub?.cancel());
    _accelSub = null;
    unawaited(_gyroSub?.cancel());
    _gyroSub = null;

    final lapDuration = s.currentLapDurationSeconds;
    final lapDistance = s.currentLapDistanceMeters;
    final endedAt = DateTime.now();
    final laps = (lapDuration > 0 || lapDistance > 0)
        ? [
            ...s.laps,
            WorkoutLap(
              index: s.laps.length + 1,
              startedAt: s.currentLapStartedAt,
              endedAt: endedAt,
              durationSeconds: lapDuration,
              distanceMeters: lapDistance,
            ),
          ]
        : s.laps;
    state = s.copyWith(
      isPaused: true,
      endedAt: endedAt,
      laps: laps,
    );
  }

  void discard() {
    _cleanup();
    state = null;
  }

  void _cleanup() {
    _ticker?.cancel();
    _ticker = null;
    unawaited(_locSub?.cancel());
    _locSub = null;
    unawaited(_accelSub?.cancel());
    _accelSub = null;
    unawaited(_gyroSub?.cancel());
    _gyroSub = null;
  }
}

final workoutControllerProvider =
    NotifierProvider<WorkoutController, WorkoutSession?>(
  WorkoutController.new,
);
