import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/skeleton/skeleton.dart';

class NutritionSkeleton extends StatelessWidget {
  const NutritionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CalorieRingCardSkeleton(),
          SizedBox(height: spacing.stackMd),
          const _MacroBarSkeleton(),
          SizedBox(height: spacing.stackMd),
          const _LiquidsCardSkeleton(),
          SizedBox(height: spacing.stackMd),
          const _MealBreakdownBarSkeleton(),
          SizedBox(height: spacing.stackLg),
          const _LoggedFoodListSkeleton(),
        ],
      ),
    );
  }
}

class _CalorieRingCardSkeleton extends StatelessWidget {
  const _CalorieRingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GlassCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonCircle(size: 180),
            SizedBox(height: spacing.stackMd),
            const SkeletonBone(width: 120, height: 16),
          ],
        ),
      ),
    );
  }
}

class _MacroBarSkeleton extends StatelessWidget {
  const _MacroBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      children: [
        const Expanded(child: _MacroPillSkeleton()),
        SizedBox(width: spacing.gutter / 2),
        const Expanded(child: _MacroPillSkeleton()),
        SizedBox(width: spacing.gutter / 2),
        const Expanded(child: _MacroPillSkeleton()),
      ],
    );
  }
}

class _MacroPillSkeleton extends StatelessWidget {
  const _MacroPillSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.stackMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBone(width: 56, height: 10),
          SizedBox(height: spacing.stackSm),
          const SkeletonBone(width: 48, height: 18),
          SizedBox(height: spacing.stackSm / 2),
          const SkeletonBone(width: 70, height: 12),
          SizedBox(height: spacing.stackSm),
          const SkeletonBone.pill(width: double.infinity, height: 4),
        ],
      ),
    );
  }
}

class _LiquidsCardSkeleton extends StatelessWidget {
  const _LiquidsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.stackMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: radius.lgRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(
                width: 20,
                height: 20,
                radius: BorderRadius.all(Radius.circular(4)),
              ),
              SizedBox(width: spacing.stackSm),
              const SkeletonBone(width: 80, height: 10),
              const Spacer(),
              const SkeletonBone(width: 100, height: 12),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const SkeletonBone(width: 72, height: 28),
              SizedBox(width: spacing.stackSm),
              const SkeletonBone(width: 14, height: 18),
              const Spacer(),
              const SkeletonBone(width: 70, height: 12),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          const SkeletonBone.pill(width: double.infinity, height: 6),
        ],
      ),
    );
  }
}

class _MealBreakdownBarSkeleton extends StatelessWidget {
  const _MealBreakdownBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.fromLTRB(
        spacing.stackLg,
        spacing.stackMd,
        spacing.stackLg,
        spacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
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
              const SkeletonBone(width: 160, height: 10),
            ],
          ),
          SizedBox(height: spacing.stackMd),
          const SkeletonBone.pill(width: double.infinity, height: 10),
          SizedBox(height: spacing.stackMd),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const Expanded(child: _SlotTileSkeleton()),
                if (i < 3) SizedBox(width: spacing.stackSm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotTileSkeleton extends StatelessWidget {
  const _SlotTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SkeletonBox(
              width: 14,
              height: 14,
              radius: BorderRadius.all(Radius.circular(3)),
            ),
            SizedBox(width: spacing.stackSm / 2),
            const Expanded(
              child: SkeletonBone(width: 36, height: 10),
            ),
          ],
        ),
        SizedBox(height: spacing.stackSm / 2),
        const SkeletonBone(width: 40, height: 18),
      ],
    );
  }
}

class _LoggedFoodListSkeleton extends StatelessWidget {
  const _LoggedFoodListSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius.xlRadius,
        border: Border.all(color: colors.ghostBorder),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.stackSm / 2),
        child: Column(
          children: [
            for (var i = 0; i < 3; i++) ...[
              const _LoggedFoodTileSkeleton(),
              if (i < 2)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                  indent: spacing.stackLg,
                  endIndent: spacing.stackLg,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoggedFoodTileSkeleton extends StatelessWidget {
  const _LoggedFoodTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.stackLg,
        vertical: spacing.stackMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkeletonCircle(size: 36),
          SizedBox(width: spacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBone(width: 140, height: 16),
                SizedBox(height: spacing.stackSm / 2),
                const SkeletonBone(width: 90, height: 12),
              ],
            ),
          ),
          SizedBox(width: spacing.stackSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SkeletonBone(width: 40, height: 18),
              SizedBox(height: spacing.stackSm / 2),
              const SkeletonBone(width: 28, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
