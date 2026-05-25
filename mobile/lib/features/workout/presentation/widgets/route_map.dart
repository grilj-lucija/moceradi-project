import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/config/env.dart';
import 'package:health_app/core/map/tile_cache.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:latlong2/latlong.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({
    required this.points,
    this.follow = false,
    this.fitBounds = false,
    this.initialCenter,
    super.key,
  });

  final List<WorkoutPoint> points;
  final bool follow;
  final bool fitBounds;
  final LatLng? initialCenter;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap>
    with SingleTickerProviderStateMixin {
  late final MapController _controller;
  late final AnimationController _markerCtrl;
  bool _didFitOnce = false;
  LatLng? _fromPos;
  LatLng? _toPos;

  static const _minInterp = Duration(milliseconds: 250);
  static const _maxInterp = Duration(milliseconds: 3000);
  static const _defaultInterp = Duration(milliseconds: 1000);

  static const List<double> _darkenMatrix = [
    0.55, 0, 0, 0, 0,
    0, 0.58, 0, 0, 0,
    0, 0, 0.68, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _controller = MapController();
    _markerCtrl = AnimationController(vsync: this, duration: _defaultInterp);
    _markerCtrl.addListener(_onMarkerTick);
    if (widget.points.isNotEmpty) {
      final p = widget.points.last;
      _fromPos = LatLng(p.lat, p.lng);
      _toPos = _fromPos;
    }
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLastPoint(oldWidget.points);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFitBoundsOnce());
  }

  @override
  void dispose() {
    _markerCtrl
      ..removeListener(_onMarkerTick)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onMarkerTick() {
    if (!mounted) return;
    if (widget.follow) {
      final pos = _currentMarkerLatLng;
      if (pos != null) {
        _controller.move(pos, _controller.camera.zoom);
      }
    }
    setState(() {});
  }

  LatLng? get _currentMarkerLatLng {
    if (_fromPos == null || _toPos == null) return _toPos;
    final t = _markerCtrl.value;
    return LatLng(
      _fromPos!.latitude + (_toPos!.latitude - _fromPos!.latitude) * t,
      _fromPos!.longitude + (_toPos!.longitude - _fromPos!.longitude) * t,
    );
  }

  void _syncLastPoint(List<WorkoutPoint> oldPoints) {
    final pts = widget.points;
    if (pts.isEmpty) return;
    final newTarget = LatLng(pts.last.lat, pts.last.lng);
    if (_toPos == null) {
      _fromPos = newTarget;
      _toPos = newTarget;
      return;
    }
    final sameTarget = _toPos!.latitude == newTarget.latitude &&
        _toPos!.longitude == newTarget.longitude;
    if (sameTarget) return;
    final currentDisplayed = _currentMarkerLatLng ?? _toPos!;
    _fromPos = currentDisplayed;
    _toPos = newTarget;
    var dur = _defaultInterp;
    if (pts.length >= 2) {
      final ms = pts.last.t.difference(pts[pts.length - 2].t).inMilliseconds;
      if (ms > 0) {
        dur = Duration(
          milliseconds: ms.clamp(
            _minInterp.inMilliseconds,
            _maxInterp.inMilliseconds,
          ),
        );
      }
    }
    _markerCtrl
      ..stop()
      ..duration = dur;
    unawaited(_markerCtrl.forward(from: 0));
  }

  void _syncFitBoundsOnce() {
    if (!mounted) return;
    if (!widget.fitBounds || _didFitOnce) return;
    if (widget.points.length < 2) return;
    final pts = widget.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList(growable: false);
    final bounds = LatLngBounds.fromPoints(pts);
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
    _didFitOnce = true;
  }

  LatLng get _initialCenter {
    if (widget.points.isNotEmpty) {
      final p = widget.points.first;
      return LatLng(p.lat, p.lng);
    }
    return widget.initialCenter ?? const LatLng(46.5547, 15.6459);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final token = Env.mapboxPublicToken;

    final rawPoints = widget.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList(growable: false);
    final liveHead = _currentMarkerLatLng;
    final livePolyline = rawPoints.isEmpty
        ? const <LatLng>[]
        : (liveHead == null ? rawPoints : [...rawPoints, liveHead]);

    return ClipRRect(
      borderRadius: radius.xlRadius,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFF05070B)),
          ),
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 16,
              minZoom: 2,
              maxZoom: 19,
              backgroundColor: const Color(0xFF05070B),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}@2x?access_token=$token',
                userAgentPackageName: 'com.feri.health_app',
                maxNativeZoom: 19,
                tileProvider: MapTileCache.provider() ?? NetworkTileProvider(),
                keepBuffer: 4,
                tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                  colorFilter: const ColorFilter.matrix(_darkenMatrix),
                  child: tileWidget,
                ),
              ),
              if (livePolyline.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: livePolyline,
                      strokeWidth: 16,
                      color: colors.enduranceCyan.withValues(alpha: 0.12),
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    Polyline(
                      points: livePolyline,
                      strokeWidth: 10,
                      color: colors.enduranceCyan.withValues(alpha: 0.25),
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    Polyline(
                      points: livePolyline,
                      strokeWidth: 4,
                      color: colors.enduranceCyan,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
              if (rawPoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    if (rawPoints.length > 1)
                      Marker(
                        point: rawPoints.first,
                        width: 14,
                        height: 14,
                        child: _StartDot(color: colors.enduranceCyan),
                      ),
                    Marker(
                      point: liveHead ?? rawPoints.last,
                      width: 28,
                      height: 28,
                      child: _EndDot(color: colors.enduranceCyan),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartDot extends StatelessWidget {
  const _StartDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
        ],
      ),
    );
  }
}

class _EndDot extends StatelessWidget {
  const _EndDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.85), blurRadius: 12),
            BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 24),
          ],
        ),
      ),
    );
  }
}
