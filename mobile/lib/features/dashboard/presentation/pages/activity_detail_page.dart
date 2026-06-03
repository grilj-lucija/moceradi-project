import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/dashboard/presentation/providers/activity_detail_controller.dart';
import 'package:health_app/features/workout/presentation/widgets/route_preview.dart';
import 'package:health_app/features/workout/services/format.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class ActivityDetailPage extends ConsumerWidget {
  const ActivityDetailPage({required this.activity, super.key});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final streamsAsync = ref.watch(activityStreamsProvider(activity.id));

    final fullPoints = streamsAsync.value == null
        ? null
        : [
            for (var i = 0; i < streamsAsync.value!.lats.length; i++)
              LatLng(
                streamsAsync.value!.lats[i],
                streamsAsync.value!.lngs[i],
              ),
          ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(activity.title ?? activity.type.label),
        leading: const BackButton(),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            spacing.containerMarginMobile,
            spacing.stackMd,
            spacing.containerMarginMobile,
            spacing.stackLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideIn(
                offset: 12,
                child: ClipRRect(
                  borderRadius: context.radius.xlRadius,
                  child: RoutePreview(
                    polyline: activity.summaryPolyline,
                    points: fullPoints,
                    bounds: activity.bounds,
                    height: 280,
                    interactive: true,
                    animate: true,
                    animationDuration: const Duration(milliseconds: 1386),
                  ),
                ),
              ),
              SizedBox(height: spacing.stackLg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 220),
                child: _Header(activity: activity),
              ),
              SizedBox(height: spacing.stackLg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 380),
                child: _Metrics(activity: activity),
              ),
              if (activity.laps.length > 1) ...[
                SizedBox(height: spacing.sectionGap),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 540),
                  child: Text('Laps', style: typography.titleMd),
                ),
                SizedBox(height: spacing.stackMd),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 620),
                  child: _Laps(activity: activity),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = 16,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.delayed(widget.delay).then((_) {
      if (!mounted) return;
      unawaited(_c.forward());
    }));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(activity.type.icon, color: colors.enduranceCyan, size: 28),
        SizedBox(width: spacing.stackMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title ?? activity.type.label,
                style: typography.headlineLgMobile,
              ),
              SizedBox(height: spacing.stackSm / 2),
              Text(
                _formatStarted(activity.startedAt),
                style: typography.bodyMd
                    .copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatStarted(DateTime startedAt) {
    final local = startedAt.toLocal();
    return DateFormat('EEEE, MMM d • HH:mm').format(local);
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final usesPace = activity.type.usesPace;
    final avgSpeed = activity.durationSeconds <= 0
        ? 0.0
        : activity.distanceMeters / activity.durationSeconds;
    final paceValue = usesPace
        ? formatPacePerKm(avgSpeed)
        : formatSpeedKmh(avgSpeed);
    final paceUnit = usesPace ? '/km' : 'km/h';
    final paceLabel = usesPace ? 'Avg pace' : 'Avg speed';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Distance',
                value: formatDistanceKm(activity.distanceMeters),
                unit: 'km',
                icon: Icons.straighten,
                highlight: true,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Duration',
                value: formatDuration(activity.duration),
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.gutter),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: paceLabel,
                value: paceValue,
                unit: paceUnit,
                icon: Icons.speed,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Calories',
                value: activity.caloriesKcal == null
                    ? '—'
                    : formatKcal(activity.caloriesKcal!),
                unit: activity.caloriesKcal == null ? '' : 'kcal',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.gutter),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Elevation',
                value: activity.elevationGainMeters == null
                    ? '—'
                    : formatElevation(activity.elevationGainMeters!),
                unit: activity.elevationGainMeters == null ? '' : 'm',
                icon: Icons.terrain,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Avg HR',
                value: activity.averageHeartRate == null
                    ? '—'
                    : activity.averageHeartRate!.toString(),
                unit: activity.averageHeartRate == null ? '' : 'bpm',
                icon: Icons.favorite_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Laps extends StatelessWidget {
  const _Laps({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;
    final speeds = activity.laps.map((l) => l.avgSpeedMps).toList();
    final fastest = speeds.fold<double>(0, (m, s) => s > m ? s : m);
    final slowest = speeds.fold<double>(
      double.infinity,
      (m, s) => s > 0 && s < m ? s : m,
    );
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < activity.laps.length; i++) ...[
            _LapRow(
              lap: activity.laps[i],
              type: activity.type,
              fastestSpeedMps: fastest,
              slowestSpeedMps: slowest.isFinite ? slowest : 0,
            ),
            if (i < activity.laps.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.outlineVariant.withValues(alpha: 0.3),
                indent: spacing.stackLg,
                endIndent: spacing.stackLg,
              ),
          ],
        ],
      ),
    );
  }
}

class _LapRow extends StatelessWidget {
  const _LapRow({
    required this.lap,
    required this.type,
    required this.fastestSpeedMps,
    required this.slowestSpeedMps,
  });

  final ActivityLap lap;
  final ActivityType type;
  final double fastestSpeedMps;
  final double slowestSpeedMps;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final paceValue = type.usesPace
        ? formatPacePerKm(lap.avgSpeedMps)
        : formatSpeedKmh(lap.avgSpeedMps);
    final range = fastestSpeedMps - slowestSpeedMps;
    final ratio = range <= 0
        ? 1.0
        : ((lap.avgSpeedMps - slowestSpeedMps) / range).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackLg,
        vertical: spacing.stackMd,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${lap.index}',
              style: typography.titleMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${formatDistanceKm(lap.distanceMeters)} km',
                      style: typography.bodyMd,
                    ),
                    SizedBox(width: spacing.stackMd),
                    Text(
                      formatDuration(lap.duration),
                      style: typography.bodyMd
                          .copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(height: spacing.stackSm / 2),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: colors.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.stackMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: radius.smRadius,
            ),
            child: Text(
              '$paceValue ${type.paceUnit}',
              style: typography.labelMd.copyWith(
                color: colors.enduranceCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
