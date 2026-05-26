import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_spacing.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/features/auth/presentation/providers/user_goals_provider.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/presentation/widgets/activity_card.dart';
import 'package:health_app/features/dashboard/presentation/widgets/daily_energy_hero.dart';
import 'package:health_app/features/dashboard/presentation/widgets/today_stats_row.dart';
import 'package:health_app/features/dashboard/presentation/widgets/weekly_activity_goal_card.dart';
import 'package:health_app/shared/widgets/layout/page_header.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final goals = ref.watch(currentUserGoalsProvider).value;

    final now = DateTime.now();
    final title = _greeting(now.hour);
    final dateLine = DateFormat('EEE, MMM d').format(now).toUpperCase();

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
          PageHeader(eyebrow: dateLine, title: title),
          SizedBox(height: spacing.stackLg),
          const DailyEnergyHero(),
          SizedBox(height: spacing.stackLg),
          const WeeklyActivityGoalCard(),
          SizedBox(height: spacing.stackLg),
          const TodayStatsRow(),
          if ((goals?.intents ?? const []).isNotEmpty) ...[
            SizedBox(height: spacing.stackLg),
            _IntentsRow(intents: goals!.intents),
          ],
          SizedBox(height: spacing.sectionGap),
          _SectionHeader(
            title: 'Recent activities',
            onViewAll: () => context.push(AppRoutes.activitiesHistory),
          ),
          SizedBox(height: spacing.stackMd),
          activitiesAsync.when(
            data: (items) {
              if (items.isEmpty) return _EmptyState(spacing: spacing);
              final shown = items.take(3).toList();
              return Column(
                children: [
                  for (final activity in shown) ...[
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

  static String _greeting(int hour) {
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 22) return 'Good evening';
    return 'Good night';
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

class _IntentsRow extends StatelessWidget {
  const _IntentsRow({required this.intents});

  final List<GoalType> intents;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR FOCUS',
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: spacing.stackSm),
        Wrap(
          spacing: spacing.gutter / 2,
          runSpacing: spacing.gutter / 2,
          children: [
            for (final intent in intents)
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: radius.pill,
                  border: Border.all(color: colors.ghostBorder),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.stackMd,
                  vertical: spacing.stackSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      intent.icon,
                      size: 14,
                      color: colors.enduranceCyan,
                    ),
                    SizedBox(width: spacing.stackSm),
                    Text(
                      intent.label,
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
