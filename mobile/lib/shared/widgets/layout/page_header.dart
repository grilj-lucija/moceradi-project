import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/navigation/profile_avatar_button.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.eyebrow,
    this.showProfileAction = true,
    this.trailing,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final bool showProfileAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: typography.labelMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: spacing.stackSm / 2),
              ],
              Text(title, style: typography.headlineLgMobile),
            ],
          ),
        ),
        if (trailing != null) ...[
          trailing!,
          SizedBox(width: spacing.stackSm),
        ],
        if (showProfileAction) const ProfileAvatarButton(),
      ],
    );
  }
}
