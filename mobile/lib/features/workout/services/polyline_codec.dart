import 'dart:math' as math;

import 'package:health_app/features/workout/domain/workout_session.dart';

class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;
}

String encodePolyline(Iterable<LatLng> points) {
  final buf = StringBuffer();
  var prevLat = 0;
  var prevLng = 0;
  for (final p in points) {
    final lat = (p.lat * 1e5).round();
    final lng = (p.lng * 1e5).round();
    _encodeValue(lat - prevLat, buf);
    _encodeValue(lng - prevLng, buf);
    prevLat = lat;
    prevLng = lng;
  }
  return buf.toString();
}

List<LatLng> decodePolyline(String encoded) {
  final out = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  while (index < encoded.length) {
    var result = 0;
    var shift = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dLat;
    result = 0;
    shift = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dLng;
    out.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return out;
}

void _encodeValue(int value, StringBuffer buf) {
  var v = value < 0 ? ~(value << 1) : (value << 1);
  while (v >= 0x20) {
    buf.writeCharCode((0x20 | (v & 0x1f)) + 63);
    v >>= 5;
  }
  buf.writeCharCode(v + 63);
}

List<WorkoutPoint> downsamplePoints(
  List<WorkoutPoint> points, {
  int maxPoints = 300,
}) {
  if (points.length <= maxPoints || points.length < 3) return points;
  final stride = math.max(1, (points.length / maxPoints).floor());
  final out = <WorkoutPoint>[];
  for (var i = 0; i < points.length; i += stride) {
    out.add(points[i]);
  }
  if (out.last != points.last) out.add(points.last);
  return out;
}
