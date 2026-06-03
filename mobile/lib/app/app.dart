import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/app/router.dart';
import 'package:health_app/app/theme/app_theme.dart';
import 'package:health_app/features/auth/presentation/providers/mqtt_session_provider.dart';
import 'package:health_app/features/settings/presentation/providers/theme_mode_controller.dart';

class HealthApp extends ConsumerWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(mqttSessionProvider);
    final router = ref.watch(routerProvider);
    final mode =
        ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: 'Health App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
