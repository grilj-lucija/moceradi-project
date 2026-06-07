import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log food'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.containerMarginMobile,
          spacing.stackLg,
          spacing.containerMarginMobile,
          spacing.stackLg,
        ),
        children: [
          _ActionCard(
            icon: Icons.qr_code_scanner,
            title: 'Scan barcode',
            subtitle: 'Point your camera at a product label',
            onTap: () => context.push(AppRoutes.nutritionScan),
          ),
          SizedBox(height: spacing.stackMd),
          _ActionCard(
            icon: Icons.search,
            title: 'Search & add',
            subtitle: 'Search generic foods, your library, and recent items',
            onTap: () => context.push(AppRoutes.nutritionSearch),
          ),
          SizedBox(height: spacing.stackMd),
          _ActionCard(
            icon: Icons.camera_alt_outlined,
            title: 'Photo (AI)',
            subtitle: 'Snap a photo and let AI estimate what you ate',
            onTap: () => context.push(AppRoutes.nutritionPhoto),
            highlight: true,
          ),
          SizedBox(height: spacing.stackMd),
          _ActionCard(
            icon: Icons.edit_note,
            title: 'Create custom food',
            subtitle: 'Enter your own kcal and macros',
            onTap: () => context.push(AppRoutes.nutritionCustom),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

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
            color: highlight
                ? colors.surfaceContainerHigh
                : colors.surfaceContainer,
            borderRadius: radius.xlRadius,
            border: Border.all(
              color: highlight ? colors.velocityBlue : colors.ghostBorder,
              width: highlight ? 1.5 : 1,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: colors.velocityBlue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: radius.lgRadius,
                  border: Border.all(color: colors.ghostBorder),
                ),
                child: Icon(
                  icon,
                  color: colors.enduranceCyan,
                  size: 28,
                ),
              ),
              SizedBox(width: spacing.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.titleMd),
                    SizedBox(height: spacing.stackSm / 2),
                    Text(
                      subtitle,
                      style: typography.bodyMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.stackSm),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
