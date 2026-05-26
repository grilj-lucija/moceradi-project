import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/features/profile/presentation/widgets/achievements_strip.dart';
import 'package:health_app/features/profile/presentation/widgets/profile_banner.dart';
import 'package:health_app/features/profile/presentation/widgets/profile_stats_strip.dart';
import 'package:health_app/features/profile/presentation/widgets/weekly_compact_card.dart';
import 'package:health_app/features/profile/presentation/widgets/weight_progress_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final profileAsync = ref.watch(currentProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: colors.background,
        body: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => SafeArea(
            child: Padding(
              padding: EdgeInsets.all(spacing.stackLg),
              child: Text(
                'Could not load profile: $e',
                style: typography.bodyMd.copyWith(color: colors.error),
              ),
            ),
          ),
          data: (profile) => _Body(profile: profile),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ListView(
          padding: EdgeInsets.only(
            top: mediaTop + 80,
            bottom: spacing.sectionGap,
          ),
          children: [
            Center(child: _AvatarFrame(profile: profile)),
            SizedBox(height: spacing.stackMd),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.containerMarginMobile,
              ),
              child: _Identity(profile: profile),
            ),
            SizedBox(height: spacing.stackLg),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.containerMarginMobile,
              ),
              child: ProfileStatsStrip(profile: profile),
            ),
            SizedBox(height: spacing.stackMd),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.containerMarginMobile,
              ),
              child: const WeeklyCompactCard(),
            ),
            SizedBox(height: spacing.stackMd),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.containerMarginMobile,
              ),
              child: WeightProgressCard(profile: profile),
            ),
            SizedBox(height: spacing.sectionGap),
            const AchievementsStrip(),
            SizedBox(height: spacing.sectionGap),
            const Center(child: _SignOutButton()),
          ],
        ),
        Positioned(
          top: mediaTop + 8,
          left: 8,
          child: const ProfileBackButton(),
        ),
      ],
    );
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({required this.profile});

  final Profile? profile;

  static const double _diameter = 120;

  String _initials() {
    final name = (profile?.presentationName ?? 'Athlete').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    final a = parts.first.characters.first;
    final b = parts.last.characters.first;
    return '$a$b'.toUpperCase();
  }

  ImageProvider? _resolveImage() {
    final url = profile?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex == -1) return null;
      try {
        final bytes = base64Decode(url.substring(commaIndex + 1));
        return MemoryImage(bytes);
      } on FormatException {
        return null;
      }
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    final image = _resolveImage();

    final body = ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: _diameter,
          height: _diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: image == null
                ? colors.surfaceContainerHigh.withValues(alpha: 0.6)
                : null,
            image: image == null
                ? null
                : DecorationImage(image: image, fit: BoxFit.cover),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: image == null
              ? Text(
                  _initials(),
                  style: typography.headlineLgMobile.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: () => context.push(AppRoutes.editProfile),
        borderRadius: radius.pill,
        child: body,
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final displayName = profile?.presentationName ?? 'Athlete';
    final username = profile?.username;

    return Column(
      children: [
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: typography.headlineLgMobile,
        ),
        SizedBox(height: spacing.stackSm / 2),
        Text(
          username == null ? 'add a username' : '@$username',
          style: typography.bodyMd.copyWith(
            color: username == null
                ? colors.onSurfaceVariant
                : colors.enduranceCyan,
          ),
        ),
        SizedBox(height: spacing.stackMd),
        _EditProfileButton(),
      ],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: () => unawaited(_onPressed(context, ref)),
        borderRadius: radius.pill,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackLg,
            vertical: spacing.stackSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'Sign out',
                style: typography.labelMd.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: () => context.push(AppRoutes.editProfile),
        borderRadius: radius.pill,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackLg,
            vertical: spacing.stackSm,
          ),
          decoration: BoxDecoration(
            borderRadius: radius.pill,
            border: Border.all(color: colors.ghostBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: colors.onSurface,
              ),
              SizedBox(width: spacing.stackSm),
              Text(
                'Edit profile',
                style: typography.labelMd.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
