import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/workout/domain/workout_session.dart';
import 'package:health_app/features/workout/presentation/providers/workout_controller.dart';
import 'package:health_app/shared/widgets/layout/page_header.dart';

class SelectActivityPage extends ConsumerWidget {
  const SelectActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.containerMarginMobile,
        spacing.stackLg,
        spacing.containerMarginMobile,
        spacing.sectionGap + 80,
      ),
      children: [
        const PageHeader(eyebrow: 'New workout', title: 'Start a workout'),
        SizedBox(height: spacing.stackSm),
        Text(
          'Pick an activity. We will track your route, pace, and calories.',
          style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(height: spacing.stackLg),
        _ActivityCard(
          type: ActivityType.walking,
          caption: 'A casual stroll. Steady pace, low intensity.',
          onTap: () => _start(context, ref, ActivityType.walking),
        ),
        SizedBox(height: spacing.stackMd),
        _ActivityCard(
          type: ActivityType.running,
          caption: 'Push your pace. Higher MET, more calories.',
          onTap: () => _start(context, ref, ActivityType.running),
        ),
        SizedBox(height: spacing.stackMd),
        _ActivityCard(
          type: ActivityType.cycling,
          caption: 'On the bike. Distance over time, lower impact.',
          onTap: () => _start(context, ref, ActivityType.cycling),
        ),
      ],
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    ActivityType type,
  ) async {
    final controller = ref.read(workoutControllerProvider.notifier);
    final error = await controller.start(type);
    if (!context.mounted) return;
    if (error == WorkoutStartError.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is required to track your workout.',
          ),
        ),
      );
      return;
    }
    await context.push<void>(AppRoutes.workoutActive);
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.type,
    required this.caption,
    required this.onTap,
  });

  final ActivityType type;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.xlRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.xlRadius,
        child: Ink(
          padding: EdgeInsets.all(spacing.stackLg),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: radius.xlRadius,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: radius.lgRadius,
                  gradient: colors.primaryGradient,
                ),
                child: Icon(type.icon, color: Colors.white, size: 28),
              ),
              SizedBox(width: spacing.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label, style: typography.titleMd),
                    SizedBox(height: spacing.stackSm / 2),
                    Text(
                      caption,
                      style: typography.bodyMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
