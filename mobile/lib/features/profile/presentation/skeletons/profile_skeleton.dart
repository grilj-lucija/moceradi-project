import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/profile/presentation/widgets/profile_banner.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/skeleton/skeleton.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final mediaTop = MediaQuery.viewPaddingOf(context).top;

    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ProfileGradient(),
        ),
        SkeletonGroup(
          child: ListView(
            padding: EdgeInsets.only(
              top: mediaTop + 80,
              bottom: spacing.sectionGap,
            ),
            children: [
              const Center(child: SkeletonCircle(size: 120)),
              SizedBox(height: spacing.stackMd),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                ),
                child: const _IdentitySkeleton(),
              ),
              SizedBox(height: spacing.stackLg),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                ),
                child: const _StatsStripSkeleton(),
              ),
              SizedBox(height: spacing.stackMd),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                ),
                child: const _WeeklyCompactCardSkeleton(),
              ),
              SizedBox(height: spacing.stackMd),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                ),
                child: const _WeightProgressCardSkeleton(),
              ),
              SizedBox(height: spacing.stackMd),
              const Center(
                child: SkeletonBone(width: 160, height: 36),
              ),
              SizedBox(height: spacing.sectionGap),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.containerMarginMobile,
                ),
                child: const _AchievementsStripSkeleton(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdentitySkeleton extends StatelessWidget {
  const _IdentitySkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      children: [
        const Center(child: SkeletonBone(width: 180, height: 24)),
        SizedBox(height: spacing.stackSm),
        const Center(child: SkeletonBone(width: 120, height: 14)),
        SizedBox(height: spacing.stackMd),
        const Center(
          child: SkeletonBone(
            width: 130,
            height: 36,
            radius: BorderRadius.all(Radius.circular(999)),
          ),
        ),
      ],
    );
  }
}

class _StatsStripSkeleton extends StatelessWidget {
  const _StatsStripSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackMd,
        vertical: spacing.stackLg,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 3; i++) ...[
              const Expanded(child: _StatColSkeleton()),
              if (i < 2)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.stackSm,
                  ),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: context.colors.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColSkeleton extends StatelessWidget {
  const _StatColSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SkeletonBox(
          width: 20,
          height: 20,
          radius: BorderRadius.all(Radius.circular(4)),
        ),
        SizedBox(height: spacing.stackSm),
        const SkeletonBone(width: 48, height: 22),
        SizedBox(height: spacing.stackSm / 2),
        const SkeletonBone(width: 60, height: 10),
      ],
    );
  }
}

class _WeeklyCompactCardSkeleton extends StatelessWidget {
  const _WeeklyCompactCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GlassCard(
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
              const SkeletonBone(width: 130, height: 10),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          Row(
            children: [
              const SkeletonCircle(size: 64),
              SizedBox(width: spacing.stackLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBone(width: 140, height: 22),
                    SizedBox(height: spacing.stackSm),
                    const SkeletonBone(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightProgressCardSkeleton extends StatelessWidget {
  const _WeightProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GlassCard(
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
                child: SkeletonBone(width: 100, height: 10),
              ),
              const SkeletonBone(width: 70, height: 12),
            ],
          ),
          SizedBox(height: spacing.stackLg),
          const SkeletonBone(width: 140, height: 28),
          SizedBox(height: spacing.stackSm),
          const SkeletonBone.pill(width: double.infinity, height: 8),
          SizedBox(height: spacing.stackSm),
          const SkeletonBone(width: 160, height: 12),
        ],
      ),
    );
  }
}

class _AchievementsStripSkeleton extends StatelessWidget {
  const _AchievementsStripSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBone(width: 140, height: 14),
        SizedBox(height: spacing.stackMd),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => SizedBox(width: spacing.stackMd),
            itemBuilder: (_, _) => const SkeletonBox(
              width: 88,
              height: 88,
              radius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
