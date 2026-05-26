import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/shared/widgets/buttons/glass_icon_button.dart';

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.person_outline,
      tooltip: 'Profile',
      onPressed: () => context.push(AppRoutes.profile),
    );
  }
}
