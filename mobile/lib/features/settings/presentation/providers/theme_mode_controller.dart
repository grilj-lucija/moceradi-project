import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/settings/data/theme_preferences_repository.dart';

final themePreferencesRepositoryProvider =
    Provider<ThemePreferencesRepository>((ref) {
  return ThemePreferencesRepository();
});

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final repo = ref.read(themePreferencesRepositoryProvider);
    return repo.load();
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final repo = ref.read(themePreferencesRepositoryProvider);
    await repo.save(mode);
  }
}

final themeModeControllerProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
