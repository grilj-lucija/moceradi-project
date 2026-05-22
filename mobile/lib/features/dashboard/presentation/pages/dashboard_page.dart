import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_spacing.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/presentation/widgets/activity_card.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';
import 'package:health_app/shared/widgets/layout/page_header.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final activities = ref.watch(recentActivitiesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(recentActivitiesProvider.future),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackLg,
          spacing.containerMarginMobile,
          spacing.sectionGap + 80,
        ),
        children: [
          const PageHeader(eyebrow: 'Today', title: "Let's flow"),
          SizedBox(height: spacing.stackLg),
          GlassCard(
            child: Row(
              children: [
                ProgressRing(
                  progress: 0.68,
                  size: 96,
                  child: Text(
                    '68%',
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
                      Text(
                        'Weekly goal',
                        style: typography.labelMd.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.stackSm / 2),
                      Text('34 / 50 km', style: typography.titleMd),
                      SizedBox(height: spacing.stackSm),
                      Text(
                        '16 km to go this week',
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
          SizedBox(height: spacing.stackLg),
          Row(
            children: [
              const Expanded(
                child: MetricTile(
                  label: 'Avg pace',
                  value: '5:24',
                  unit: '/km',
                  icon: Icons.speed,
                  highlight: true,
                ),
              ),
              SizedBox(width: spacing.gutter),
              const Expanded(
                child: MetricTile(
                  label: 'Resting HR',
                  value: '54',
                  unit: 'bpm',
                  icon: Icons.favorite_outline,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sectionGap),
          Text('Recent activities', style: typography.titleMd),
          SizedBox(height: spacing.stackMd),
          activities.when(
            data: (items) => items.isEmpty
                ? _EmptyState(spacing: spacing)
                : Column(
                    children: [
                      for (final activity in items) ...[
                        ActivityCard(
                          activity: activity,
                          onTap: () => context.push(
                            AppRoutes.activityDetail,
                            extra: activity,
                          ),
                        ),
                        SizedBox(height: spacing.stackMd),
                      ],
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'Could not load activities: $e',
              style: typography.bodyMd.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.spacing});
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.all(spacing.stackLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: colors.onSurfaceVariant),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Text(
              'No activities yet.\nStart a workout to see it here.',
              style: typography.bodyMd
                  .copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
