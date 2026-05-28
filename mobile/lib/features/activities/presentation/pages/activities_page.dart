import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_spacing.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/activities/presentation/skeletons/activities_skeleton.dart';
import 'package:health_app/features/activities/presentation/widgets/weekly_bars_card.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/presentation/widgets/activity_card.dart';
import 'package:health_app/features/dashboard/presentation/widgets/weekly_activity_goal_card.dart';
import 'package:health_app/features/dashboard/services/activity_progress.dart';
import 'package:health_app/shared/widgets/buttons/floating_action_pill.dart';
import 'package:health_app/shared/widgets/layout/page_header.dart';
import 'package:intl/intl.dart';

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final eyebrow = DateFormat('EEE, MMM d').format(DateTime.now()).toUpperCase();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => ref.refresh(recentActivitiesProvider.future),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              spacing.containerMarginMobile,
              spacing.stackLg,
              spacing.containerMarginMobile,
              FloatingActionPill.reservedListPadding(context),
            ),
            children: [
              PageHeader(eyebrow: eyebrow, title: 'Activities'),
              SizedBox(height: spacing.stackLg),
              const WeeklyActivityGoalCard(),
              SizedBox(height: spacing.stackLg),
              const WeeklyBarsCard(),
              SizedBox(height: spacing.sectionGap),
              _SectionHeader(
                title: 'This week',
                onViewAll: () => context.push(AppRoutes.activitiesHistory),
              ),
              SizedBox(height: spacing.stackMd),
              activitiesAsync.when(
                data: (items) {
                  final weekStart =
                      ActivityProgress.startOfWeek(DateTime.now());
                  final weekItems =
                      ActivityProgress.filterSince(items, weekStart);
                  if (weekItems.isEmpty) {
                    return _EmptyState(
                      spacing: spacing,
                      hasHistory: items.isNotEmpty,
                    );
                  }
                  return Column(
                    children: [
                      for (final activity in weekItems) ...[
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
                  );
                },
                loading: () => const ActivitiesListSkeleton(),
                error: (e, _) => Text(
                  'Could not load activities: $e',
                  style: typography.bodyMd.copyWith(color: colors.error),
                ),
              ),
            ],
          ),
        ),
        FloatingActionPill(
          label: 'Start activity',
          icon: Icons.add,
          onPressed: () => context.push(AppRoutes.workoutStart),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: typography.titleMd)),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.stackSm,
              vertical: 0,
            ),
            minimumSize: const Size(0, 32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View all',
                style: typography.labelMd.copyWith(
                  color: colors.enduranceCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colors.enduranceCyan,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.spacing, required this.hasHistory});

  final AppSpacing spacing;
  final bool hasHistory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final copy = hasHistory
        ? 'Nothing logged this week yet.\nTap Start activity to get moving.'
        : 'No activities yet.\nTap Start activity to log your first one.';
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
              copy,
              style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
