import 'package:health_app/features/workout/domain/workout_session.dart';

double estimateKcal({
  required ActivityType type,
  required double weightKg,
  required Duration duration,
}) {
  if (duration.inSeconds <= 0 || weightKg <= 0) return 0;
  return type.metValue * weightKg * duration.inSeconds / 3600.0;
}
