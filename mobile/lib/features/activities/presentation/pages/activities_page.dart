import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: const Text('All activities')),
      body: Padding(
        padding: spacing.pagePadding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timeline,
                size: 48,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              SizedBox(height: spacing.stackMd),
              Text(
                'All activities coming soon',
                style: typography.titleMd,
              ),
              SizedBox(height: spacing.stackSm),
              Text(
                'Full history, filters, and charts land here next.',
                textAlign: TextAlign.center,
                style: typography.bodyMd
                    .copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
