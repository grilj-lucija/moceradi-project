import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/data/models/user_goals.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';

class ProfileStatsStrip extends ConsumerWidget {
  const ProfileStatsStrip({required this.profile, super.key});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spacing = context.spacing;

    final streak = ref.watch(dailyStreakProvider);
    final weekly = ref.watch(weeklyActivityProgressProvider);

    final weeklyValue = weekly == null
        ? '—'
        : (weekly.metric.isInteger
            ? weekly.value.round().toString()
            : weekly.value.toStringAsFixed(1));
    final weeklyUnit = weekly?.metric.unit ?? '';
    final weeklyLabel = weekly == null
        ? 'WEEKLY'
        : weekly.metric.shortLabel.toUpperCase();

    final current = profile?.weightKg;
    final target = profile?.targetWeightKg;
    final hasWeight = current != null && target != null;
    final delta = hasWeight ? (target - current) : null;
    final weightValue = delta == null
        ? (current?.toStringAsFixed(0) ?? '—')
        : delta.abs().toStringAsFixed(1);
    final weightUnit = current == null ? null : 'kg';
    final weightLabel = delta == null
        ? 'WEIGHT'
        : (delta < 0 ? 'TO LOSE' : delta > 0 ? 'TO GAIN' : 'ON TARGET');
    final weightIcon = delta == null
        ? Icons.monitor_weight_outlined
        : (delta < 0
            ? Icons.trending_down
            : delta > 0
                ? Icons.trending_up
                : Icons.check_circle_outline);

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackMd,
        vertical: spacing.stackLg,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatColumn(
                icon: Icons.local_fire_department_outlined,
                value: streak.toString(),
                label: streak == 1 ? 'DAY STREAK' : 'DAY STREAK',
                accent: streak > 0,
              ),
            ),
            VerticalDivider(color: colors.outlineVariant, width: 1),
            Expanded(
              child: _StatColumn(
                icon: weekly?.metric.icon ?? Icons.directions_run,
                value: weeklyValue,
                unit: weeklyUnit.isEmpty ? null : weeklyUnit,
                label: weeklyLabel,
                accent: false,
              ),
            ),
            VerticalDivider(color: colors.outlineVariant, width: 1),
            Expanded(
              child: _StatColumn(
                icon: weightIcon,
                value: weightValue,
                unit: weightUnit,
                label: weightLabel,
                accent: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    this.unit,
    this.accent = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final iconColor = accent ? colors.enduranceCyan : colors.onSurfaceVariant;
    final valueColor = accent ? colors.enduranceCyan : colors.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        SizedBox(height: spacing.stackSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.titleMd.copyWith(
                  color: valueColor,
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (unit != null) ...[
              SizedBox(width: spacing.stackSm / 2),
              Text(
                unit!,
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: spacing.stackSm / 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 1.5,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
