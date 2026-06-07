import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesRepository {
  ThemePreferencesRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _key = 'theme_mode';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<ThemeMode> load() async {
    final prefs = await _instance();
    final raw = prefs.getString(_key);
    return _decode(raw);
  }

  Future<void> save(ThemeMode mode) async {
    final prefs = await _instance();
    await prefs.setString(_key, _encode(mode));
  }

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
