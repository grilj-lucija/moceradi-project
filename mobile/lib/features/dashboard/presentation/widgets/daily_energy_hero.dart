import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/skeletons/dashboard_skeleton.dart';
import 'package:health_app/features/nutrition/presentation/providers/daily_nutrition_controller.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/progress/progress_ring.dart';
import 'package:intl/intl.dart';

class DailyEnergyHero extends ConsumerWidget {
  const DailyEnergyHero({super.key});

  static final _fmt = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final state = ref.watch(dailyNutritionControllerProvider);

    return Material(
      color: Colors.transparent,
      borderRadius: radius.xlRadius,
      child: InkWell(
        onTap: () => context.go(AppRoutes.nutrition),
        borderRadius: radius.xlRadius,
        child: GlassCard(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackLg,
            vertical: spacing.stackMd,
          ),
          child: state.when(
            loading: () => const DailyEnergyHeroSkeletonContent(),
            error: (e, _) => SizedBox(
              height: 96,
              child: Center(
                child: Text(
                  'Could not load nutrition.',
                  style: typography.bodyMd.copyWith(color: colors.error),
                ),
              ),
            ),
            data: (s) {
              final consumed = s.totals.kcal;
              final goal = s.goal.kcal;
              final hasGoal = goal > 0;
              final progress = hasGoal ? consumed / goal : 0.0;
              final diff = consumed - goal;
              final isOver = hasGoal && diff > 0;
              final remaining = hasGoal
                  ? (goal - consumed).clamp(0.0, double.infinity)
                  : 0.0;
              final summaryNumber = isOver
                  ? _fmt.format(diff.round())
                  : _fmt.format(remaining.round());
              final summaryLabel = isOver ? 'kcal over' : 'kcal left';
              final summaryColor =
                  isOver ? colors.error : colors.enduranceCyan;

              return Row(
                children: [
                  ProgressRing(
                    progress: progress,
                    size: 76,
                    strokeWidth: 7,
                    child: Text(
                      _fmt.format(consumed.round()),
                      style: typography.titleMd.copyWith(
                        color: colors.onSurface,
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
                          "TODAY'S ENERGY",
                          style: typography.labelMd.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: spacing.stackSm / 2),
                        Text(
                          hasGoal
                              ? '${_fmt.format(consumed.round())} / ${_fmt.format(goal.round())} kcal'
                              : '${_fmt.format(consumed.round())} kcal',
                          style: typography.titleMd,
                        ),
                        if (hasGoal) ...[
                          SizedBox(height: spacing.stackSm / 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                summaryNumber,
                                style: typography.bodyMd
                                    .copyWith(color: summaryColor),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                summaryLabel,
                                style: typography.labelMd.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
