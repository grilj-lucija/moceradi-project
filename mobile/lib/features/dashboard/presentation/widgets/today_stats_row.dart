import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';

class TodayStatsRow extends ConsumerWidget {
  const TodayStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.spacing;
    final stats = ref.watch(todayActivityStatsProvider);

    final minutes = stats.activeMinutes;
    final mins = minutes >= 60
        ? (minutes / 60).toStringAsFixed(1)
        : minutes.toString();
    final minsUnit = minutes >= 60 ? 'h' : 'min';

    return Row(
      children: [
        Expanded(
          child: MetricTile(
            label: 'Burned today',
            value: stats.caloriesBurned == 0
                ? '0'
                : stats.caloriesBurned.round().toString(),
            unit: 'kcal',
            icon: Icons.local_fire_department_outlined,
            highlight: stats.caloriesBurned > 0,
          ),
        ),
        SizedBox(width: spacing.gutter),
        Expanded(
          child: MetricTile(
            label: 'Active today',
            value: mins,
            unit: minsUnit,
            icon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }
}
