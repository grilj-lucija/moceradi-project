import 'package:equatable/equatable.dart';

enum ActivityType { run, ride, walk, swim, other }

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.startedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    this.averageHeartRate,
    this.elevationGainMeters,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        type: ActivityType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ActivityType.other,
        ),
        startedAt: DateTime.parse(json['started_at'] as String),
        durationSeconds: (json['duration_seconds'] as num).toInt(),
        distanceMeters: (json['distance_meters'] as num).toDouble(),
        averageHeartRate: (json['avg_heart_rate'] as num?)?.toInt(),
        elevationGainMeters: (json['elevation_gain_m'] as num?)?.toDouble(),
      );

  final String id;
  final String title;
  final ActivityType type;
  final DateTime startedAt;
  final int durationSeconds;
  final double distanceMeters;
  final int? averageHeartRate;
  final double? elevationGainMeters;

  Duration get duration => Duration(seconds: durationSeconds);
  double get distanceKm => distanceMeters / 1000;
  double get paceMinPerKm =>
      distanceMeters == 0 ? 0 : (durationSeconds / 60) / distanceKm;

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        startedAt,
        durationSeconds,
        distanceMeters,
        averageHeartRate,
        elevationGainMeters,
      ];
}
