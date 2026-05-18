import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:health_app/features/workout/presentation/providers/workout_controller.dart';
import 'package:health_app/features/workout/presentation/widgets/route_map.dart';
import 'package:health_app/features/workout/services/format.dart';
import 'package:health_app/shared/widgets/buttons/primary_button.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';

class WorkoutSummaryPage extends ConsumerWidget {
  const WorkoutSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutControllerProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.dashboard);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _SummaryBody(session: session);
  }
}

class _SummaryBody extends ConsumerWidget {
  const _SummaryBody({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final controller = ref.read(workoutControllerProvider.notifier);
    final paceUnit = session.type.paceUnit;
    final paceValue = session.type.usesPace
        ? formatPacePerKm(session.avgSpeedMps)
        : formatSpeedKmh(session.avgSpeedMps);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.containerMarginMobile,
                spacing.stackMd,
                spacing.containerMarginMobile,
                spacing.stackLg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colors.enduranceCyan,
                    size: 22,
                  ),
                  SizedBox(width: spacing.stackSm),
                  Text(
                    'Workout complete',
                    style: typography.titleMd,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.containerMarginMobile,
                  0,
                  spacing.containerMarginMobile,
                  spacing.stackLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: RouteMap(
                        points: session.points,
                        fitBounds: true,
                      ),
                    ),
                    SizedBox(height: spacing.stackLg),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Distance',
                            value: formatDistanceKm(session.distanceMeters),
                            unit: 'km',
                            icon: Icons.straighten,
                            highlight: true,
                          ),
                        ),
                        SizedBox(width: spacing.gutter),
                        Expanded(
                          child: MetricTile(
                            label: 'Duration',
                            value: formatDuration(session.duration),
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
                            label: session.type.usesPace
                                ? 'Avg pace'
                                : 'Avg speed',
                            value: paceValue,
                            unit: paceUnit,
                            icon: Icons.speed,
                          ),
                        ),
                        SizedBox(width: spacing.gutter),
                        Expanded(
                          child: MetricTile(
                            label: 'Calories',
                            value: formatKcal(session.caloriesKcal),
                            unit: 'kcal',
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
                            value: formatElevation(session.elevationGainMeters),
                            unit: 'm',
                            icon: Icons.terrain,
                          ),
                        ),
                        SizedBox(width: spacing.gutter),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                    if (session.laps.length > 1) ...[
                      SizedBox(height: spacing.sectionGap),
                      _LapsSection(session: session),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.containerMarginMobile,
                spacing.stackSm,
                spacing.containerMarginMobile,
                spacing.stackLg,
              ),
              child: PrimaryButton(
                label: 'Done',
                onPressed: () {
                  controller.discard();
                  context.go(AppRoutes.dashboard);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LapsSection extends StatelessWidget {
  const _LapsSection({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final speeds = session.laps.map((l) => l.avgSpeedMps).toList();
    final fastest = speeds.fold<double>(0, (m, s) => s > m ? s : m);
    final slowest = speeds.fold<double>(
      double.infinity,
      (m, s) => s > 0 && s < m ? s : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.stackSm / 2),
          child: Text('Laps', style: typography.titleMd),
        ),
        SizedBox(height: spacing.stackMd),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: radius.xlRadius,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < session.laps.length; i++) ...[
                _LapRow(
                  lap: session.laps[i],
                  type: session.type,
                  fastestSpeedMps: fastest,
                  slowestSpeedMps: slowest.isFinite ? slowest : 0,
                ),
                if (i < session.laps.length - 1)
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
        ),
      ],
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

  final WorkoutLap lap;
  final WorkoutType type;
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
                      style: typography.bodyMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
