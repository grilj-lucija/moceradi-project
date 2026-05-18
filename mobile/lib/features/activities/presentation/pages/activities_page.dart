import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    return Padding(
      padding: spacing.pagePadding,
      child: Center(
        child: Text('Activities (coming soon)', style: typography.titleMd),
      ),
    );
  }
}
