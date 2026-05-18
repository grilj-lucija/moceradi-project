import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
    this.scrollable = false,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final content = Padding(
      padding: padding ?? spacing.pagePadding,
      child: body,
    );

    return Scaffold(
      extendBody: bottomNavigationBar != null,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!, style: typography.headlineLgMobile),
              actions: actions,
              backgroundColor: colors.background,
            ),
      body: scrollable ? SingleChildScrollView(child: content) : content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
