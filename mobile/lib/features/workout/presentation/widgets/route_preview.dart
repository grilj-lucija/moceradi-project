import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/config/env.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/workout/services/polyline_codec.dart' as pl;
import 'package:latlong2/latlong.dart';

double _haversineMeters(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude) * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final sLat = math.sin(dLat / 2);
  final sLng = math.sin(dLng / 2);
  final h = sLat * sLat +
      math.cos(a.latitude * math.pi / 180) *
          math.cos(b.latitude * math.pi / 180) *
          sLng *
          sLng;
  return 2 * r * math.asin(math.min(1, math.sqrt(h)));
}

class RoutePreview extends StatefulWidget {
  const RoutePreview({
    this.polyline,
    this.points,
    this.bounds,
    this.height = 140,
    this.interactive = false,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 1134),
    super.key,
  });

  final String? polyline;
  final List<LatLng>? points;
  final ActivityBounds? bounds;
  final double height;
  final bool interactive;
  final bool animate;
  final Duration animationDuration;

  @override
  State<RoutePreview> createState() => _RoutePreviewState();
}

class _RoutePreviewState extends State<RoutePreview>
    with SingleTickerProviderStateMixin {
  late final MapController _controller = MapController();
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeInCubic,
  );
  bool _didFit = false;
  bool _didStartAnim = false;
  List<LatLng>? _animPoints;
  List<double>? _animCumDist;
  double _animTotalDist = 0;

  static const List<double> _darkenMatrix = [
    0.5, 0, 0, 0, 0,
    0, 0.53, 0, 0, 0,
    0, 0, 0.63, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<LatLng> get _points {
    if (widget.points != null && widget.points!.isNotEmpty) {
      return widget.points!;
    }
    final encoded = widget.polyline;
    if (encoded == null || encoded.isEmpty) return const [];
    return [
      for (final p in pl.decodePolyline(encoded)) LatLng(p.lat, p.lng),
    ];
  }

  LatLng get _initialCenter {
    final pts = _points;
    if (pts.isNotEmpty) return pts.first;
    final b = widget.bounds;
    if (b != null) {
      return LatLng((b.north + b.south) / 2, (b.east + b.west) / 2);
    }
    return const LatLng(46.5547, 15.6459);
  }

  void _fitOnce(List<LatLng> pts) {
    if (_didFit || pts.length < 2) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(pts),
          padding: const EdgeInsets.all(24),
        ),
      );
      _didFit = true;
    });
  }

  void _maybeStartAnim(List<LatLng> pts) {
    if (!widget.animate || _didStartAnim || pts.length < 2) return;
    _didStartAnim = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_animController.forward(from: 0));
    });
  }

  void _prepareAnimPoints(List<LatLng> pts) {
    if (_animPoints != null) return;
    if (pts.length < 2) return;
    final cum = <double>[0];
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += _haversineMeters(pts[i - 1], pts[i]);
      cum.add(total);
    }
    _animPoints = pts;
    _animCumDist = cum;
    _animTotalDist = total;
  }

  List<LatLng> _sliceByDistance(double t) {
    final pts = _animPoints;
    final cum = _animCumDist;
    if (pts == null || cum == null || pts.length < 2) return const [];
    if (t <= 0) return pts.sublist(0, 1);
    if (t >= 1 || _animTotalDist <= 0) return pts;
    final target = t * _animTotalDist;
    var lo = 0;
    var hi = cum.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (cum[mid] <= target) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    if (lo >= pts.length - 1) return pts;
    final base = pts.sublist(0, lo + 1);
    final segStart = cum[lo];
    final segEnd = cum[lo + 1];
    final segLen = segEnd - segStart;
    if (segLen <= 0) return base;
    final frac = ((target - segStart) / segLen).clamp(0.0, 1.0);
    final a = pts[lo];
    final b = pts[lo + 1];
    return [
      ...base,
      LatLng(
        a.latitude + (b.latitude - a.latitude) * frac,
        a.longitude + (b.longitude - a.longitude) * frac,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final token = Env.mapboxPublicToken;
    final pts = _points;
    if (widget.animate) _prepareAnimPoints(pts);
    _fitOnce(pts);
    _maybeStartAnim(pts);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFF05070B)),
          ),
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14,
              minZoom: 2,
              maxZoom: 19,
              backgroundColor: const Color(0xFF05070B),
              interactionOptions: InteractionOptions(
                flags: widget.interactive
                    ? InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom
                    : InteractiveFlag.none,
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
              if (pts.length >= 2)
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    final List<LatLng> visible;
                    if (widget.animate && _animPoints != null) {
                      visible = _sliceByDistance(_progress.value);
                    } else {
                      visible = pts;
                    }
                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: visible,
                          strokeWidth: 12,
                          color: colors.enduranceCyan.withValues(alpha: 0.12),
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                        Polyline(
                          points: visible,
                          strokeWidth: 6,
                          color: colors.enduranceCyan.withValues(alpha: 0.25),
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                        Polyline(
                          points: visible,
                          strokeWidth: 3,
                          color: colors.enduranceCyan,
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
