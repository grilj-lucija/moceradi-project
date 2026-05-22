import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/workout/presentation/widgets/route_preview.dart';
import 'package:health_app/features/workout/services/format.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.activity, this.onTap, super.key});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.xlRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.xlRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: radius.xlRadius,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: ClipRRect(
            borderRadius: radius.xlRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Preview(activity: activity),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.stackMd,
                    spacing.stackMd,
                    spacing.stackMd,
                    spacing.stackMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TitleRow(activity: activity),
                      SizedBox(height: spacing.stackSm / 2),
                      _SubtitleRow(activity: activity),
                      SizedBox(height: spacing.stackMd),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: spacing.stackMd),
                      _StatsRow(activity: activity),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasTrack = (activity.summaryPolyline ?? '').isNotEmpty;

    if (!hasTrack) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.surfaceContainerHigh,
              colors.surfaceContainerLow,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            activity.type.icon,
            size: 36,
            color: colors.onSurfaceVariant.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    return RoutePreview(
      polyline: activity.summaryPolyline,
      bounds: activity.bounds,
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Row(
      children: [
        Icon(activity.type.icon, size: 18, color: colors.enduranceCyan),
        SizedBox(width: spacing.stackSm),
        Expanded(
          child: Text(
            activity.title ?? activity.type.label,
            style: typography.titleMd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Text(
      _formatStarted(activity.startedAt),
      style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
    );
  }

  static String _formatStarted(DateTime startedAt) {
    final local = startedAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = day.difference(today).inDays;
    final hhmm = DateFormat('HH:mm').format(local);
    if (diff == 0) return 'Today, $hhmm';
    if (diff == -1) return 'Yesterday, $hhmm';
    return DateFormat('MMM d, HH:mm').format(local);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final usesPace = activity.type.usesPace;
    final paceLabel = usesPace ? 'AVG PACE' : 'AVG SPEED';
    final paceValue = usesPace
        ? formatPacePerKm(_avgSpeedMps(activity))
        : formatSpeedKmh(_avgSpeedMps(activity));
    final paceUnit = usesPace ? '/km' : 'km/h';

    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: 'DISTANCE',
            value: formatDistanceKm(activity.distanceMeters),
            unit: 'km',
          ),
        ),
        Expanded(
          child: _Stat(
            label: 'DURATION',
            value: formatDuration(activity.duration),
            unit: '',
          ),
        ),
        Expanded(
          child: _Stat(
            label: paceLabel,
            value: paceValue,
            unit: paceUnit,
            accent: true,
          ),
        ),
      ],
    );
  }

  static double _avgSpeedMps(Activity a) {
    if (a.durationSeconds <= 0) return 0;
    return a.distanceMeters / a.durationSeconds;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.unit,
    this.accent = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        SizedBox(height: spacing.stackSm / 2),
        RichText(
          text: TextSpan(
            style: typography.titleMd.copyWith(
              color: accent ? colors.enduranceCyan : colors.onSurface,
            ),
            children: [
              TextSpan(text: value),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: typography.labelMd.copyWith(
                    color: accent
                        ? colors.enduranceCyan.withValues(alpha: 0.8)
                        : colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
