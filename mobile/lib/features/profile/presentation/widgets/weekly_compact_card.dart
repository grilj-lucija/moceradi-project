import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/services/activity_progress.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';

class WeeklyCompactCard extends ConsumerWidget {
  const WeeklyCompactCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final progress = ref.watch(weeklyActivityProgressProvider);
    final intents = ref.watch(currentUserGoalsProvider).value?.intents ??
        const <GoalType>[];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_outlined,
                size: 18,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'THIS WEEK',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          _Body(progress: progress, intents: intents),
          SizedBox(height: spacing.stackLg),
          Center(child: _EditGoalsPill()),
        ],
      ),
    );
  }
}

class _EditGoalsPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: () => context.push(AppRoutes.editGoals),
        borderRadius: radius.pill,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackLg,
            vertical: spacing.stackSm,
          ),
          decoration: BoxDecoration(
            color: colors.enduranceCyan.withValues(alpha: 0.14),
            borderRadius: radius.pill,
            border: Border.all(
              color: colors.enduranceCyan.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                size: 16,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'Edit goals & nutrition plan',
                style: typography.labelMd.copyWith(
                  color: colors.enduranceCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.progress, required this.intents});

  final WeeklyActivityProgress? progress;
  final List<GoalType> intents;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    if (progress == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 28,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Text(
              'Pick a weekly goal to start tracking progress.',
              style: typography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final p = progress!;
    final isInt = p.metric.isInteger;
    final valueStr = isInt
        ? p.value.round().toString()
        : p.value.toStringAsFixed(1);
    final targetStr = isInt
        ? p.target.round().toString()
        : p.target.toStringAsFixed(1);
    final unit = p.metric.unit;
    final percent = (p.fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressRing(
              progress: p.fraction,
              size: 92,
              strokeWidth: 7,
              child: Text(
                '$percent%',
                style: typography.titleMd.copyWith(
                  color: colors.enduranceCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: spacing.stackLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.metric.shortLabel,
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: spacing.stackSm / 2),
                  RichText(
                    text: TextSpan(
                      style: typography.bodyLg.copyWith(
                        color: colors.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: valueStr,
                          style: typography.titleMd.copyWith(
                            color: colors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' / $targetStr',
                          style: typography.bodyLg.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (unit.isNotEmpty)
                          TextSpan(
                            text: ' $unit',
                            style: typography.bodyMd.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.stackSm),
                  Text(
                    p.isComplete
                        ? 'Weekly goal hit. Nice.'
                        : '${_remainingStr(p)} ${unit.isEmpty ? '' : '$unit '}to go',
                    style: typography.labelMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (intents.isNotEmpty) ...[
          SizedBox(height: spacing.stackLg),
          Divider(color: colors.outlineVariant, height: 1),
          SizedBox(height: spacing.stackMd),
          Wrap(
            spacing: spacing.gutter / 2,
            runSpacing: spacing.gutter / 2,
            children: [
              for (final g in intents)
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: radius.pill,
                    border: Border.all(color: colors.ghostBorder),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.stackMd,
                    vertical: spacing.stackSm / 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(g.icon, size: 14, color: colors.enduranceCyan),
                      SizedBox(width: spacing.stackSm / 2),
                      Text(
                        g.label,
                        style: typography.labelMd.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _remainingStr(WeeklyActivityProgress p) {
    if (p.metric.isInteger) return p.remaining.round().toString();
    return p.remaining.toStringAsFixed(1);
  }
}
