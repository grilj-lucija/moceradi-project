import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/weight/presentation/providers/weight_controller.dart';
import 'package:health_app/features/weight/presentation/widgets/log_weight_sheet.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';

class WeeklyWeightReminderCard extends ConsumerWidget {
  const WeeklyWeightReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final entry = ref.watch(currentWeekWeightProvider);

    final shouldShow = entry.maybeWhen(
      data: (value) => value == null,
      orElse: () => false,
    );
    if (!shouldShow) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.enduranceCyan.withValues(alpha: 0.14),
                  borderRadius: radius.mdRadius,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.monitor_weight_outlined,
                  color: colors.enduranceCyan,
                ),
              ),
              SizedBox(width: spacing.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY CHECK-IN',
                      style: typography.labelMd.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: spacing.stackSm / 2),
                    Text('Time to weigh in', style: typography.titleMd),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.stackMd),
          Text(
            "Log this week's weight to keep your progress accurate.",
            style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: spacing.stackLg),
          Align(
            alignment: Alignment.centerLeft,
            child: _LogWeightCta(
              onTap: () => LogWeightSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogWeightCta extends StatelessWidget {
  const _LogWeightCta({required this.onTap});

  final VoidCallback onTap;

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
        onTap: onTap,
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
                Icons.add,
                size: 16,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'Log weight',
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
