import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
    required this.weekStart,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] as String,
        weightKg: (json['weight_kg'] as num).toDouble(),
        loggedAt: DateTime.parse(json['logged_at'] as String),
        weekStart: DateTime.parse(json['week_start'] as String),
      );

  final String id;
  final double weightKg;
  final DateTime loggedAt;
  final DateTime weekStart;

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight_kg': weightKg,
        'logged_at': loggedAt.toIso8601String(),
        'week_start':
            '${weekStart.year.toString().padLeft(4, '0')}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}',
      };

  @override
  List<Object?> get props => [id, weightKg, loggedAt, weekStart];
}
