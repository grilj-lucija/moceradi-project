String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  String two(int n) => n.toString().padLeft(2, '0');
  if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
  return '${two(m)}:${two(s)}';
}

String formatDistanceKm(double meters) {
  final km = meters / 1000.0;
  if (km < 10) return km.toStringAsFixed(2);
  return km.toStringAsFixed(1);
}

String formatSpeedKmh(double mps) {
  if (mps <= 0) return '0.0';
  return (mps * 3.6).toStringAsFixed(1);
}

String formatPacePerKm(double mps) {
  if (mps <= 0.05) return '—';
  final secPerKm = 1000.0 / mps;
  final minutes = secPerKm ~/ 60;
  final seconds = (secPerKm - minutes * 60).round();
  if (seconds == 60) return '${minutes + 1}:00';
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatKcal(double kcal) {
  if (kcal < 100) return kcal.toStringAsFixed(0);
  return kcal.round().toString();
}

String formatElevation(double meters) {
  if (meters < 100) return meters.toStringAsFixed(0);
  return meters.round().toString();
}
