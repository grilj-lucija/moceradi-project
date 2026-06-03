import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ActivityType { walking, running, cycling }

extension ActivityTypeX on ActivityType {
  String get label => switch (this) {
        ActivityType.walking => 'Walking',
        ActivityType.running => 'Running',
        ActivityType.cycling => 'Cycling',
      };

  IconData get icon => switch (this) {
        ActivityType.walking => Icons.directions_walk,
        ActivityType.running => Icons.directions_run,
        ActivityType.cycling => Icons.directions_bike,
      };

  double get metValue => switch (this) {
        ActivityType.walking => 3.5,
        ActivityType.running => 9.8,
        ActivityType.cycling => 7.5,
      };

  bool get usesPace => switch (this) {
        ActivityType.walking => true,
        ActivityType.running => true,
        ActivityType.cycling => false,
      };

  String get paceUnit => usesPace ? '/km' : 'km/h';

  String get wire => name;

  static ActivityType fromWire(String value) =>
      ActivityType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ActivityType.walking,
      );
}

class ActivityBounds extends Equatable {
  const ActivityBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  factory ActivityBounds.fromJson(Map<String, dynamic> json) =>
      ActivityBounds(
        north: (json['n'] as num).toDouble(),
        south: (json['s'] as num).toDouble(),
        east: (json['e'] as num).toDouble(),
        west: (json['w'] as num).toDouble(),
      );

  final double north;
  final double south;
  final double east;
  final double west;

  Map<String, dynamic> toJson() => {
        'n': north,
        's': south,
        'e': east,
        'w': west,
      };

  @override
  List<Object?> get props => [north, south, east, west];
}

class ActivityLap extends Equatable {
  const ActivityLap({
    required this.index,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.distanceMeters,
  });

  factory ActivityLap.fromJson(Map<String, dynamic> json) => ActivityLap(
        index: (json['index'] as num).toInt(),
        startedAt: DateTime.parse(json['started_at'] as String),
        endedAt: DateTime.parse(json['ended_at'] as String),
        durationSeconds: (json['duration_seconds'] as num).toInt(),
        distanceMeters: (json['distance_meters'] as num).toDouble(),
      );

  final int index;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final double distanceMeters;

  Duration get duration => Duration(seconds: durationSeconds);

  double get avgSpeedMps =>
      durationSeconds <= 0 ? 0 : distanceMeters / durationSeconds;

  Map<String, dynamic> toJson() => {
        'index': index,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'duration_seconds': durationSeconds,
        'distance_meters': distanceMeters,
      };

  @override
  List<Object?> get props =>
      [index, startedAt, endedAt, durationSeconds, distanceMeters];
}

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    this.title,
    this.description,
    this.endedAt,
    this.movingSeconds,
    this.elevationGainMeters,
    this.elevationLossMeters,
    this.averageHeartRate,
    this.maxHeartRate,
    this.avgPaceSecondsPerKm,
    this.maxSpeedMps,
    this.caloriesKcal,
    this.weightKg,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.bounds,
    this.summaryPolyline,
    this.laps = const [],
    this.source = 'workout',
    this.visibility = 'private',
    this.externalId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final lapsRaw = json['laps'];
    final laps = lapsRaw is List
        ? [
            for (final l in lapsRaw)
              ActivityLap.fromJson(l as Map<String, dynamic>),
          ]
        : const <ActivityLap>[];
    final boundsRaw = json['bounds'];
    return Activity(
      id: json['id'] as String,
      type: ActivityTypeX.fromWire(json['type'] as String),
      title: json['title'] as String?,
      description: json['description'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      movingSeconds: (json['moving_seconds'] as num?)?.toInt(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      elevationGainMeters: (json['elevation_gain_meters'] as num?)?.toDouble(),
      elevationLossMeters: (json['elevation_loss_meters'] as num?)?.toDouble(),
      averageHeartRate: (json['avg_heart_rate'] as num?)?.toInt(),
      maxHeartRate: (json['max_heart_rate'] as num?)?.toInt(),
      avgPaceSecondsPerKm: (json['avg_pace_s_per_km'] as num?)?.toDouble(),
      maxSpeedMps: (json['max_speed_mps'] as num?)?.toDouble(),
      caloriesKcal: (json['calories_kcal'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      startLat: (json['start_lat'] as num?)?.toDouble(),
      startLng: (json['start_lng'] as num?)?.toDouble(),
      endLat: (json['end_lat'] as num?)?.toDouble(),
      endLng: (json['end_lng'] as num?)?.toDouble(),
      bounds: boundsRaw is Map<String, dynamic>
          ? ActivityBounds.fromJson(boundsRaw)
          : null,
      summaryPolyline: json['summary_polyline'] as String?,
      laps: laps,
      source: (json['source'] as String?) ?? 'workout',
      visibility: (json['visibility'] as String?) ?? 'private',
      externalId: json['external_id'] as String?,
    );
  }

  final String id;
  final ActivityType type;
  final String? title;
  final String? description;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int? movingSeconds;
  final double distanceMeters;
  final double? elevationGainMeters;
  final double? elevationLossMeters;
  final int? averageHeartRate;
  final int? maxHeartRate;
  final double? avgPaceSecondsPerKm;
  final double? maxSpeedMps;
  final double? caloriesKcal;
  final double? weightKg;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final ActivityBounds? bounds;
  final String? summaryPolyline;
  final List<ActivityLap> laps;
  final String source;
  final String visibility;
  final String? externalId;

  Duration get duration => Duration(seconds: durationSeconds);
  double get distanceKm => distanceMeters / 1000;
  double get paceMinPerKm =>
      distanceMeters == 0 ? 0 : (durationSeconds / 60) / distanceKm;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        startedAt,
        endedAt,
        durationSeconds,
        movingSeconds,
        distanceMeters,
        elevationGainMeters,
        elevationLossMeters,
        averageHeartRate,
        maxHeartRate,
        avgPaceSecondsPerKm,
        maxSpeedMps,
        caloriesKcal,
        weightKg,
        startLat,
        startLng,
        endLat,
        endLng,
        bounds,
        summaryPolyline,
        laps,
        source,
        visibility,
        externalId,
      ];
}

class ActivityStreams extends Equatable {
  const ActivityStreams({
    required this.activityId,
    required this.timeOffsetsMs,
    required this.lats,
    required this.lngs,
    this.altitudes,
    this.speedsMps,
    this.heartRates,
    this.cadences,
    this.powersW,
    this.temperaturesC,
  });

  factory ActivityStreams.fromJson(Map<String, dynamic> json) =>
      ActivityStreams(
        activityId: json['activity_id'] as String,
        timeOffsetsMs: _intList(json['time_offsets_ms']),
        lats: _doubleList(json['lats']),
        lngs: _doubleList(json['lngs']),
        altitudes: _doubleListOrNull(json['altitudes']),
        speedsMps: _doubleListOrNull(json['speeds_mps']),
        heartRates: _intListOrNull(json['heart_rates']),
        cadences: _intListOrNull(json['cadences']),
        powersW: _intListOrNull(json['powers_w']),
        temperaturesC: _doubleListOrNull(json['temperatures_c']),
      );

  final String activityId;
  final List<int> timeOffsetsMs;
  final List<double> lats;
  final List<double> lngs;
  final List<double?>? altitudes;
  final List<double?>? speedsMps;
  final List<int?>? heartRates;
  final List<int?>? cadences;
  final List<int?>? powersW;
  final List<double?>? temperaturesC;

  int get length => lats.length;

  @override
  List<Object?> get props => [
        activityId,
        timeOffsetsMs,
        lats,
        lngs,
        altitudes,
        speedsMps,
        heartRates,
        cadences,
        powersW,
        temperaturesC,
      ];
}

List<int> _intList(Object? raw) =>
    ((raw ?? const []) as List<dynamic>).map((e) => (e as num).toInt()).toList();

List<double> _doubleList(Object? raw) =>
    ((raw ?? const []) as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();

List<int?>? _intListOrNull(Object? raw) {
  if (raw == null) return null;
  return (raw as List<dynamic>)
      .map((e) => e == null ? null : (e as num).toInt())
      .toList();
}

List<double?>? _doubleListOrNull(Object? raw) {
  if (raw == null) return null;
  return (raw as List<dynamic>)
      .map((e) => e == null ? null : (e as num).toDouble())
      .toList();
}
