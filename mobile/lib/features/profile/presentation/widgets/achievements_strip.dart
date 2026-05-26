import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/dashboard/presentation/providers/dashboard_controller.dart';

class _Badge {
  const _Badge({
    required this.icon,
    required this.label,
    required this.unlocked,
  });
  final IconData icon;
  final String label;
  final bool unlocked;
}

class AchievementsStrip extends ConsumerWidget {
  const AchievementsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final streak = ref.watch(dailyStreakProvider);
    final weekly = ref.watch(weeklyActivityProgressProvider);

    final badges = <_Badge>[
      _Badge(
        icon: Icons.local_fire_department,
        label: '3-day\nstreak',
        unlocked: streak >= 3,
      ),
      _Badge(
        icon: Icons.whatshot,
        label: '7-day\nstreak',
        unlocked: streak >= 7,
      ),
      _Badge(
        icon: Icons.emoji_events_outlined,
        label: 'Weekly\ngoal hit',
        unlocked: weekly?.isComplete ?? false,
      ),
      const _Badge(
        icon: Icons.directions_run,
        label: 'First 5k',
        unlocked: false,
      ),
      const _Badge(
        icon: Icons.flag_outlined,
        label: '10\nworkouts',
        unlocked: false,
      ),
      const _Badge(
        icon: Icons.bolt,
        label: 'Power\nweek',
        unlocked: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: spacing.containerMarginMobile),
          child: Row(
            children: [
              Text(
                'ACHIEVEMENTS',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: spacing.stackSm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.stackSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: context.radius.pill,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  '${badges.where((b) => b.unlocked).length} / ${badges.length}',
                  style: typography.labelMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.stackMd),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.containerMarginMobile,
            ),
            itemCount: badges.length,
            separatorBuilder: (_, _) => SizedBox(width: spacing.stackMd),
            itemBuilder: (context, i) => _BadgeTile(badge: badges[i]),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final iconColor =
        badge.unlocked ? colors.enduranceCyan : colors.onSurfaceVariant;
    final fill = badge.unlocked
        ? colors.enduranceCyan.withValues(alpha: 0.1)
        : colors.surfaceContainerLow;
    final border = badge.unlocked ? colors.enduranceCyan : colors.outlineVariant;

    return Container(
      width: 92,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius.lgRadius,
        border: Border.all(color: border, width: badge.unlocked ? 1.5 : 1),
      ),
      padding: EdgeInsets.all(spacing.stackSm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(badge.icon, size: 32, color: iconColor),
              if (!badge.unlocked)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.stackSm),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.labelMd.copyWith(
              color: badge.unlocked ? colors.onSurface : colors.onSurfaceVariant,
              height: 1.15,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
