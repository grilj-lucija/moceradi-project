import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/core/config/env.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/workout/services/polyline_codec.dart' as pl;
import 'package:latlong2/latlong.dart';

class RoutePreview extends StatefulWidget {
  const RoutePreview({
    this.polyline,
    this.points,
    this.bounds,
    this.height = 140,
    this.interactive = false,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 1800),
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
    curve: Curves.easeOutCubic,
  );
  bool _didFit = false;
  bool _didStartAnim = false;

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

  @override
  void didUpdateWidget(covariant RoutePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.polyline != widget.polyline ||
        oldWidget.points != widget.points) {
      _didFit = false;
    }
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

  List<LatLng> _slice(List<LatLng> pts, double t) {
    if (pts.length < 2) return pts;
    if (t >= 1) return pts;
    final fullCount = (pts.length * t).clamp(0, pts.length - 1);
    final wholeCount = fullCount.floor();
    if (wholeCount <= 1) return pts.sublist(0, 2);
    final base = pts.sublist(0, wholeCount);
    final frac = fullCount - wholeCount;
    if (frac > 0 && wholeCount < pts.length) {
      final a = pts[wholeCount - 1];
      final b = pts[wholeCount];
      final lat = a.latitude + (b.latitude - a.latitude) * frac;
      final lng = a.longitude + (b.longitude - a.longitude) * frac;
      return [...base, LatLng(lat, lng)];
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final token = Env.mapboxPublicToken;
    final pts = _points;
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
                    final t = widget.animate ? _progress.value : 1.0;
                    final visible = _slice(pts, t);
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
