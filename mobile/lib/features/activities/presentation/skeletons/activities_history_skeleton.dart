import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/skeletons/dashboard_skeleton.dart';
import 'package:health_app/shared/widgets/skeleton/skeleton.dart';

class ActivitiesHistorySkeleton extends StatelessWidget {
  const ActivitiesHistorySkeleton({this.groupCount = 3, super.key});

  final int groupCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SkeletonGroup(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackLg,
          spacing.containerMarginMobile,
          spacing.sectionGap,
        ),
        children: [
          for (var g = 0; g < groupCount; g++)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sectionGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: spacing.stackSm,
                      bottom: spacing.stackMd,
                    ),
                    child: const SkeletonBone(width: 110, height: 10),
                  ),
                  const ActivityCardSkeleton(),
                  SizedBox(height: spacing.stackMd),
                  const ActivityCardSkeleton(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
