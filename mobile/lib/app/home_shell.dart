import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/shared/widgets/navigation/glass_bottom_nav.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({
    required this.currentIndex,
    required this.onTap,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.background,
      ),
      child: Scaffold(
        extendBody: true,
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: GlassBottomNav(
          currentIndex: currentIndex,
          onTap: onTap,
          items: const [
            GlassNavItem(icon: Icons.bolt_outlined, label: 'Today'),
            GlassNavItem(icon: Icons.timeline, label: 'Activities'),
            GlassNavItem(icon: Icons.restaurant_outlined, label: 'Nutrition'),
          ],
        ),
      ),
    );
  }
}
