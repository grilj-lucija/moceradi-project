import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';

class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final a = parts.first.characters.first;
    final b = parts.last.characters.first;
    return '$a$b'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    final profileAsync = ref.watch(currentProfileProvider);
    final name = profileAsync.value?.presentationName ?? 'Athlete';
    final initials = _initials(name);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius.pill,
        child: InkWell(
          onTap: () => context.push(AppRoutes.profile),
          borderRadius: radius.pill,
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: radius.pill,
              border: Border.all(color: colors.ghostBorder),
            ),
            child: Center(
              child: Text(
                initials,
                style: typography.labelMd.copyWith(
                  color: colors.enduranceCyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
