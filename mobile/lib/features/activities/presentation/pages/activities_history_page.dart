import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/activity.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/features/dashboard/presentation/widgets/activity_card.dart';
import 'package:intl/intl.dart';

class ActivitiesHistoryPage extends ConsumerWidget {
  const ActivitiesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All activities')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(recentActivitiesProvider.future),
        child: activitiesAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: EdgeInsets.all(spacing.containerMarginMobile),
                children: [
                  SizedBox(height: spacing.sectionGap),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: spacing.stackMd),
                        Text(
                          'No history yet',
                          style: typography.titleMd,
                        ),
                        SizedBox(height: spacing.stackSm),
                        Text(
                          'Your past workouts will appear here.',
                          textAlign: TextAlign.center,
                          style: typography.bodyMd.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final groups = _groupByDay(items);
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                spacing.containerMarginMobile,
                spacing.stackLg,
                spacing.containerMarginMobile,
                spacing.sectionGap,
              ),
              itemCount: groups.length,
              itemBuilder: (context, idx) {
                final group = groups[idx];
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing.sectionGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: spacing.stackSm,
                          bottom: spacing.stackMd,
                        ),
                        child: Text(
                          _dayLabel(group.day),
                          style: typography.labelMd.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      for (final activity in group.activities) ...[
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
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(spacing.stackLg),
              child: Text(
                'Could not load activities: $e',
                style: typography.bodyMd.copyWith(color: colors.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<_DayGroup> _groupByDay(List<Activity> items) {
    final sorted = [...items]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final map = <DateTime, List<Activity>>{};
    for (final a in sorted) {
      final local = a.startedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      map.putIfAbsent(day, () => []).add(a);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final d in days) _DayGroup(day: d, activities: map[d]!),
    ];
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == -1) return 'YESTERDAY';
    final sameYear = day.year == today.year;
    final pattern = sameYear ? 'EEE, MMM d' : 'EEE, MMM d yyyy';
    return DateFormat(pattern).format(day).toUpperCase();
  }
}

class _DayGroup {
  const _DayGroup({required this.day, required this.activities});
  final DateTime day;
  final List<Activity> activities;
}
