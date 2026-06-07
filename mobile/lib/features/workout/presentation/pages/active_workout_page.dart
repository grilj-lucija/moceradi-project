import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:health_app/features/workout/presentation/providers/workout_controller.dart';
import 'package:health_app/features/workout/presentation/widgets/route_map.dart';
import 'package:health_app/features/workout/services/format.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';

class ActiveWorkoutPage extends ConsumerWidget {
  const ActiveWorkoutPage({super.key});

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
    return _ActiveBody(session: session);
  }
}

class _ActiveBody extends ConsumerWidget {
  const _ActiveBody({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final controller = ref.read(workoutControllerProvider.notifier);
    final mediaQuery = MediaQuery.of(context);

    final mapHeight = mediaQuery.size.height * 0.26;
    final paceUnit = session.type.paceUnit;
    final paceValue = session.type.usesPace
        ? formatPacePerKm(session.currentSpeedMps)
        : formatSpeedKmh(session.currentSpeedMps);

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
                spacing.stackMd,
              ),
              child: Row(
                children: [
                  _LivePill(isPaused: session.isPaused),
                  const Spacer(),
                  Text(
                    session.type.label,
                    style: typography.titleMd,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.containerMarginMobile,
              ),
              child: SizedBox(
                height: mapHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.78, 1.0],
                        ).createShader(rect),
                        child: RouteMap(
                          points: session.points,
                          follow: true,
                        ),
                      ),
                    ),
                    if (session.laps.isNotEmpty)
                      Positioned(
                        left: 0,
                        bottom: spacing.stackMd,
                        child: _LapBadge(session: session),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.containerMarginMobile,
                  spacing.stackLg,
                  spacing.containerMarginMobile,
                  spacing.stackSm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Duration',
                            value: formatDuration(session.duration),
                            icon: Icons.timer_outlined,
                            highlight: true,
                          ),
                        ),
                        SizedBox(width: spacing.gutter),
                        Expanded(
                          child: MetricTile(
                            label: 'Distance',
                            value: formatDistanceKm(session.distanceMeters),
                            unit: 'km',
                            icon: Icons.straighten,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.gutter),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: session.type.usesPace ? 'Pace' : 'Speed',
                            value: paceValue,
                            unit: paceUnit,
                            icon: Icons.speed,
                          ),
                        ),
                        SizedBox(width: spacing.gutter),
                        Expanded(
                          child: MetricTile(
                            label: 'Elevation',
                            value:
                                formatElevation(session.elevationGainMeters),
                            unit: 'm',
                            icon: Icons.terrain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.gutter),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.stackLg,
                        vertical: spacing.stackMd,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: radius.xlRadius,
                        border: Border.all(color: colors.ghostBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: colors.enduranceCyan,
                            size: 20,
                          ),
                          SizedBox(width: spacing.stackSm),
                          Text(
                            'Calories',
                            style: typography.labelMd.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatKcal(session.caloriesKcal),
                            style: typography.titleMd.copyWith(
                              color: colors.enduranceCyan,
                            ),
                          ),
                          SizedBox(width: spacing.stackSm / 2),
                          Text(
                            'kcal',
                            style: typography.bodyMd.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.containerMarginMobile,
                spacing.stackLg,
                spacing.containerMarginMobile,
                spacing.stackLg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundActionButton(
                    icon: Icons.stop_rounded,
                    color: colors.error,
                    onTap: () {
                      controller.stop();
                      context.go(AppRoutes.workoutSummary);
                    },
                  ),
                  _PausePlayButton(
                    isPaused: session.isPaused,
                    onTap: () {
                      if (session.isPaused) {
                        controller.resume();
                      } else {
                        controller.pause();
                      }
                    },
                  ),
                  _RoundActionButton(
                    icon: Icons.flag_outlined,
                    color: colors.surfaceContainerHigh,
                    iconColor: colors.enduranceCyan,
                    onTap: session.isPaused ? null : controller.markLap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LapBadge extends StatelessWidget {
  const _LapBadge({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LAP ${session.currentLapIndex}',
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: spacing.stackSm / 4),
        Row(
          children: [
            Text(
              '${formatDistanceKm(session.currentLapDistanceMeters)} km',
              style: typography.bodyMd.copyWith(
                color: colors.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: spacing.stackSm),
            Text(
              '·',
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(width: spacing.stackSm),
            Text(
              formatDuration(session.currentLapDuration),
              style: typography.bodyMd.copyWith(
                color: colors.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.isPaused});

  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    final accent = isPaused ? colors.onSurfaceVariant : colors.enduranceCyan;
    final label = isPaused ? 'PAUSED' : 'LIVE • GPS ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.pill,
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: typography.labelMd.copyWith(
              color: accent,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.color,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;
    final bg = enabled ? color : colors.surfaceContainerHigh;
    final ic = iconColor ?? Colors.white;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: colors.ghostBorder),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: enabled ? ic : colors.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PausePlayButton extends StatelessWidget {
  const _PausePlayButton({required this.isPaused, required this.onTap});

  final bool isPaused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: colors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: colors.velocityBlue.withValues(alpha: 0.4),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
