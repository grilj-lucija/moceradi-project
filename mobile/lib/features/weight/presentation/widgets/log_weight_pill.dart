import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/weight/presentation/providers/weight_controller.dart';
import 'package:health_app/features/weight/presentation/widgets/log_weight_sheet.dart';

class LogWeightPill extends ConsumerWidget {
  const LogWeightPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final loggedThisWeek = ref.watch(currentWeekWeightProvider).maybeWhen(
          data: (value) => value != null,
          orElse: () => false,
        );

    final label = loggedThisWeek
        ? "Update this week's weight"
        : "Log this week's weight";

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: () => LogWeightSheet.show(context),
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
                Icons.monitor_weight_outlined,
                size: 16,
                color: colors.enduranceCyan,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                label,
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
