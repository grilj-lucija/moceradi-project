import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/skeletons/dashboard_skeleton.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/skeleton/skeleton.dart';

class ActivitiesListSkeleton extends StatelessWidget {
  const ActivitiesListSkeleton({this.itemCount = 2, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: Column(
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            const ActivityCardSkeleton(),
            if (i < itemCount - 1) SizedBox(height: spacing.stackMd),
          ],
        ],
      ),
    );
  }
}

class WeeklyBarsCardSkeleton extends StatelessWidget {
  const WeeklyBarsCardSkeleton({super.key});

  static const _heights = <double>[0.45, 0.7, 0.3, 0.85, 0.55, 0.4, 0.65];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(
                  width: 16,
                  height: 16,
                  radius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(width: spacing.stackSm),
                const Expanded(
                  child: SkeletonBone(width: 140, height: 10),
                ),
                const SkeletonBone(width: 60, height: 10),
              ],
            ),
            SizedBox(height: spacing.stackLg),
            SizedBox(
              height: 96,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final h in _heights)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: FractionallySizedBox(
                          heightFactor: h,
                          alignment: Alignment.bottomCenter,
                          child: const SkeletonBox(
                            radius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.stackSm),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  const Expanded(
                    child: Center(
                      child: SkeletonBone(width: 10, height: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
