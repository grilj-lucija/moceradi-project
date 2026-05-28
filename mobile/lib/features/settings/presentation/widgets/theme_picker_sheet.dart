import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/settings/presentation/providers/theme_mode_controller.dart';

class ThemePickerSheet extends ConsumerWidget {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final current =
        ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.ghostBorder)),
      ),
      padding: EdgeInsets.fromLTRB(
        spacing.containerMarginMobile,
        spacing.stackSm,
        spacing.containerMarginMobile,
        spacing.stackLg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: spacing.stackMd),
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: radius.pill,
                ),
              ),
            ),
            Text('Appearance', style: typography.titleMd),
            SizedBox(height: spacing.stackSm / 2),
            Text(
              'Choose how Health App looks on this device.',
              style: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
            ),
            SizedBox(height: spacing.stackLg),
            _ThemeOptionTile(
              icon: Icons.brightness_auto_outlined,
              label: 'System',
              description: 'Match the device setting',
              selected: current == ThemeMode.system,
              onTap: () => _select(context, ref, ThemeMode.system),
            ),
            SizedBox(height: spacing.stackSm),
            _ThemeOptionTile(
              icon: Icons.light_mode_outlined,
              label: 'Light',
              description: 'Off-white surfaces, navy text',
              selected: current == ThemeMode.light,
              onTap: () => _select(context, ref, ThemeMode.light),
            ),
            SizedBox(height: spacing.stackSm),
            _ThemeOptionTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark',
              description: 'Deep navy, low eye strain',
              selected: current == ThemeMode.dark,
              onTap: () => _select(context, ref, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    await ref.read(themeModeControllerProvider.notifier).setMode(mode);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final borderColor =
        selected ? colors.enduranceCyan : colors.ghostBorder;
    final iconColor =
        selected ? colors.enduranceCyan : colors.onSurfaceVariant;

    return Material(
      color: selected
          ? colors.enduranceCyan.withValues(alpha: 0.08)
          : colors.surfaceContainerHigh,
      borderRadius: radius.mdRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.mdRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.stackMd,
            vertical: spacing.stackMd,
          ),
          decoration: BoxDecoration(
            borderRadius: radius.mdRadius,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: spacing.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: spacing.stackSm / 2),
                    Text(
                      description,
                      style: typography.bodyMd
                          .copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: colors.enduranceCyan,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
