import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/skeleton/skeleton.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SkeletonGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeaderSkeleton(),
          SizedBox(height: spacing.stackLg),
          const DailyEnergyHeroSkeleton(),
          SizedBox(height: spacing.stackLg),
          const WeeklyActivityGoalCardSkeleton(),
          SizedBox(height: spacing.stackLg),
          const TodayStatsRowSkeleton(),
          SizedBox(height: spacing.sectionGap),
          const _SectionHeaderSkeleton(),
          SizedBox(height: spacing.stackMd),
          const ActivityCardSkeleton(),
          SizedBox(height: spacing.stackMd),
          const ActivityCardSkeleton(),
        ],
      ),
    );
  }
}

class PageHeaderSkeleton extends StatelessWidget {
  const PageHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBone(width: 92, height: 10),
              SizedBox(height: spacing.stackSm),
              const SkeletonBone(width: 200, height: 26),
            ],
          ),
        ),
        const SkeletonCircle(size: 40),
      ],
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonBone(width: 160, height: 20)),
        SkeletonBone(width: 60, height: 14),
      ],
    );
  }
}

class DailyEnergyHeroSkeleton extends StatelessWidget {
  const DailyEnergyHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: GlassCard(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.stackLg,
          vertical: spacing.stackMd,
        ),
        child: const DailyEnergyHeroSkeletonContent(),
      ),
    );
  }
}

class DailyEnergyHeroSkeletonContent extends StatelessWidget {
  const DailyEnergyHeroSkeletonContent({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SizedBox(
      height: 96,
      child: Row(
        children: [
          const SkeletonCircle(size: 76),
          SizedBox(width: spacing.stackLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkeletonBone(width: 110, height: 10),
                SizedBox(height: spacing.stackSm),
                const SkeletonBone(width: 160, height: 18),
                SizedBox(height: spacing.stackSm),
                const SkeletonBone(width: 80, height: 12),
              ],
            ),
          ),
          const SkeletonBone(width: 12, height: 18),
        ],
      ),
    );
  }
}

class WeeklyActivityGoalCardSkeleton extends StatelessWidget {
  const WeeklyActivityGoalCardSkeleton({super.key});

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
                const SkeletonBone(width: 160, height: 10),
              ],
            ),
            SizedBox(height: spacing.stackLg),
            Row(
              children: [
                const SkeletonCircle(size: 88),
                SizedBox(width: spacing.stackLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBone(width: 180, height: 28),
                      SizedBox(height: spacing.stackSm),
                      const SkeletonBone(width: 130, height: 14),
                      SizedBox(height: spacing.stackSm / 2),
                      const SkeletonBone(width: 100, height: 12),
                    ],
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

class TodayStatsRowSkeleton extends StatelessWidget {
  const TodayStatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: Row(
        children: [
          const Expanded(child: _MetricTileSkeleton()),
          SizedBox(width: spacing.gutter),
          const Expanded(child: _MetricTileSkeleton()),
        ],
      ),
    );
  }
}

class _MetricTileSkeleton extends StatelessWidget {
  const _MetricTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.stackLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SkeletonBox(
                width: 16,
                height: 16,
                radius: BorderRadius.all(Radius.circular(4)),
              ),
              SizedBox(width: spacing.stackSm),
              const SkeletonBone(width: 100, height: 10),
            ],
          ),
          SizedBox(height: spacing.stackMd),
          const SkeletonBone(width: 80, height: 32),
        ],
      ),
    );
  }
}

class ActivityCardSkeleton extends StatelessWidget {
  const ActivityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;

    return SkeletonGroup(
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: radius.xlRadius,
          border: Border.all(color: colors.ghostBorder),
        ),
        child: ClipRRect(
          borderRadius: radius.xlRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SkeletonBox(
                height: 140,
                radius: BorderRadius.zero,
              ),
              Padding(
                padding: EdgeInsets.all(spacing.stackMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const SkeletonBox(
                          width: 18,
                          height: 18,
                          radius: BorderRadius.all(Radius.circular(4)),
                        ),
                        SizedBox(width: spacing.stackSm),
                        const Expanded(
                          child: SkeletonBone(width: 140, height: 18),
                        ),
                        const SkeletonBox(
                          width: 18,
                          height: 18,
                          radius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.stackSm),
                    const SkeletonBone(width: 120, height: 14),
                    SizedBox(height: spacing.stackMd),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: spacing.stackMd),
                    const Row(
                      children: [
                        Expanded(child: _StatBoneCol()),
                        Expanded(child: _StatBoneCol()),
                        Expanded(child: _StatBoneCol()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBoneCol extends StatelessWidget {
  const _StatBoneCol();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBone(width: 50, height: 10),
        SizedBox(height: spacing.stackSm),
        const SkeletonBone(width: 64, height: 20),
      ],
    );
  }
}
