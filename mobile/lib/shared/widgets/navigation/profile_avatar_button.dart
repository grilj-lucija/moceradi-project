import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/shared/widgets/avatars/profile_avatar.dart';

class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ProfileAvatar(
        name: profile?.presentationName ?? 'Athlete',
        avatarUrl: profile?.avatarUrl,
        onTap: () => context.push(AppRoutes.profile),
      ),
    );
  }
}
