import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/data/models/profile.dart';
import 'package:health_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:health_app/features/auth/presentation/providers/profile_provider.dart';
import 'package:health_app/shared/widgets/buttons/ghost_button.dart';
import 'package:health_app/shared/widgets/cards/glass_card.dart';
import 'package:health_app/shared/widgets/cards/metric_tile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackMd,
          spacing.containerMarginMobile,
          spacing.sectionGap,
        ),
        children: [
          profileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'Could not load profile: $e',
              style: typography.bodyMd.copyWith(color: colors.error),
            ),
            data: (profile) => _ProfileBody(profile: profile),
          ),
          SizedBox(height: spacing.sectionGap),
          GhostButton(
            label: 'Sign out',
            icon: Icons.logout,
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final Profile? profile;

  String _genderLabel(Gender? g) => switch (g) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
        null => '—',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final displayName = profile?.presentationName ?? 'Athlete';
    final username = profile?.username;
    final email = profile?.email;
    final age = profile?.age;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: typography.titleMd),
              if (username != null) ...[
                SizedBox(height: spacing.stackSm / 2),
                Text(
                  '@$username',
                  style: typography.bodyMd.copyWith(
                    color: colors.enduranceCyan,
                  ),
                ),
              ],
              if (email != null) ...[
                SizedBox(height: spacing.stackSm),
                Text(
                  email,
                  style: typography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.stackLg),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Age',
                value: age?.toString() ?? '—',
                unit: age == null ? null : 'yrs',
                icon: Icons.cake_outlined,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Gender',
                value: _genderLabel(profile?.gender),
                icon: Icons.person_outline,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.stackMd),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Height',
                value: profile?.heightCm?.toStringAsFixed(0) ?? '—',
                unit: profile?.heightCm == null ? null : 'cm',
                icon: Icons.height,
              ),
            ),
            SizedBox(width: spacing.gutter),
            Expanded(
              child: MetricTile(
                label: 'Weight',
                value: profile?.weightKg?.toStringAsFixed(0) ?? '—',
                unit: profile?.weightKg == null ? null : 'kg',
                icon: Icons.monitor_weight_outlined,
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
