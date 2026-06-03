import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/services/activity_progress.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';

class WeeklyActivityGoalCard extends ConsumerWidget {
  const WeeklyActivityGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyActivityProgressProvider);
    return GlassCard(
      child: progress == null
          ? const _EmptyState()
          : _ProgressBody(progress: progress),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    return Row(
      children: [
        Icon(Icons.flag_outlined, color: colors.onSurfaceVariant),
        SizedBox(width: spacing.stackMd),
        Expanded(
          child: Text(
            'Set a weekly activity goal in your profile to see progress here.',
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.progress});

  final WeeklyActivityProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final metric = progress.metric;
    final isInt = metric.isInteger;
    final valueText = isInt
        ? progress.value.round().toString()
        : progress.value.toStringAsFixed(1);
    final targetText = isInt
        ? progress.target.round().toString()
        : progress.target.toStringAsFixed(0);
    final pct = (progress.fraction * 100).round();

    final remainingText = progress.isComplete
        ? 'Goal reached'
        : '${isInt ? progress.remaining.round() : progress.remaining.toStringAsFixed(1)} ${metric.unit} to go';

    final daysLeftInWeek = _daysLeftInWeek();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(metric.icon, size: 16, color: colors.enduranceCyan),
            SizedBox(width: spacing.stackSm),
            Text(
              '${metric.shortLabel.toUpperCase()} · THIS WEEK',
              style: typography.labelMd.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackLg),
        Row(
          children: [
            ProgressRing(
              progress: progress.fraction,
              size: 88,
              strokeWidth: 8,
              child: Text(
                '$pct%',
                style: typography.titleMd.copyWith(
                  color: colors.enduranceCyan,
                ),
              ),
            ),
            SizedBox(width: spacing.stackLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: typography.metricXl
                          .copyWith(color: colors.onSurface),
                      children: [
                        TextSpan(text: valueText),
                        TextSpan(
                          text: ' / $targetText',
                          style: typography.titleMd.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: ' ${metric.unit}',
                          style: typography.labelMd.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.stackSm),
                  Text(
                    remainingText,
                    style: typography.bodyMd.copyWith(
                      color: progress.isComplete
                          ? colors.enduranceCyan
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: spacing.stackSm / 2),
                  Text(
                    daysLeftInWeek == 0
                        ? 'Last day of the week'
                        : '$daysLeftInWeek day${daysLeftInWeek == 1 ? '' : 's'} left this week',
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _daysLeftInWeek() {
    final now = DateTime.now();
    return 7 - now.weekday;
  }
}
