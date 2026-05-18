import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/config/env.dart';
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

class _RouteMapState extends State<RouteMap> {
  late final MapController _controller;
  bool _didFitOnce = false;

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
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncCamera() {
    if (!mounted) return;
    if (widget.fitBounds && widget.points.length >= 2 && !_didFitOnce) {
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
      return;
    }
    if (widget.follow && widget.points.isNotEmpty) {
      final last = widget.points.last;
      _controller.move(LatLng(last.lat, last.lng), _controller.camera.zoom);
    }
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

    final latLngPoints = widget.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList(growable: false);

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
                tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                  colorFilter: const ColorFilter.matrix(_darkenMatrix),
                  child: tileWidget,
                ),
              ),
              if (latLngPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: latLngPoints,
                      strokeWidth: 16,
                      color: colors.enduranceCyan.withValues(alpha: 0.12),
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    Polyline(
                      points: latLngPoints,
                      strokeWidth: 10,
                      color: colors.enduranceCyan.withValues(alpha: 0.25),
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    Polyline(
                      points: latLngPoints,
                      strokeWidth: 4,
                      color: colors.enduranceCyan,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
              if (latLngPoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    if (latLngPoints.length > 1)
                      Marker(
                        point: latLngPoints.first,
                        width: 14,
                        height: 14,
                        child: _StartDot(color: colors.enduranceCyan),
                      ),
                    Marker(
                      point: latLngPoints.last,
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
