import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.velocityBlue,
    required this.enduranceCyan,
    required this.ghostBorder,
    required this.chartProtein,
    required this.chartCarbs,
    required this.chartFat,
    required this.chartSnack,
  });

  static const AppColors dark = AppColors(
    surface: Color(0xFF10141A),
    surfaceDim: Color(0xFF10141A),
    surfaceBright: Color(0xFF353940),
    surfaceContainerLowest: Color(0xFF0A0E14),
    surfaceContainerLow: Color(0xFF181C22),
    surfaceContainer: Color(0xFF1C2026),
    surfaceContainerHigh: Color(0xFF262A31),
    surfaceContainerHighest: Color(0xFF31353C),
    onSurface: Color(0xFFDFE2EB),
    onSurfaceVariant: Color(0xFFC1C6D7),
    outline: Color(0xFF8B90A0),
    outlineVariant: Color(0xFF414755),
    primary: Color(0xFFADC6FF),
    onPrimary: Color(0xFF002E69),
    primaryContainer: Color(0xFF4B8EFF),
    onPrimaryContainer: Color(0xFF00285C),
    secondary: Color(0xFFBDF4FF),
    onSecondary: Color(0xFF00363D),
    secondaryContainer: Color(0xFF00E3FD),
    onSecondaryContainer: Color(0xFF00616D),
    tertiary: Color(0xFFC2C1FF),
    onTertiary: Color(0xFF1C0B9F),
    tertiaryContainer: Color(0xFF8382FF),
    onTertiaryContainer: Color(0xFF150093),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF10141A),
    onBackground: Color(0xFFDFE2EB),
    velocityBlue: Color(0xFF007AFF),
    enduranceCyan: Color(0xFF00E5FF),
    ghostBorder: Color(0x1AFFFFFF),
    chartProtein: Color(0xFF00E5FF),
    chartCarbs: Color(0xFF4B8EFF),
    chartFat: Color(0xFFC2C1FF),
    chartSnack: Color(0xFFFFB088),
  );

  static const AppColors light = AppColors(
    surface: Color(0xFFF7F8FB),
    surfaceDim: Color(0xFFE2E6EF),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F3F8),
    surfaceContainer: Color(0xFFEBEEF4),
    surfaceContainerHigh: Color(0xFFE2E6EF),
    surfaceContainerHighest: Color(0xFFD8DCE6),
    onSurface: Color(0xFF10141A),
    onSurfaceVariant: Color(0xFF4A5060),
    outline: Color(0xFF6A7080),
    outlineVariant: Color(0xFFC8CDD8),
    primary: Color(0xFF007AFF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD8E2FF),
    onPrimaryContainer: Color(0xFF001A41),
    secondary: Color(0xFF006874),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF9CF0FF),
    onSecondaryContainer: Color(0xFF001F24),
    tertiary: Color(0xFF3631B4),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE2DFFF),
    onTertiaryContainer: Color(0xFF0C006A),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFF7F8FB),
    onBackground: Color(0xFF10141A),
    velocityBlue: Color(0xFF007AFF),
    enduranceCyan: Color(0xFF007AFF),
    ghostBorder: Color(0x1F0A0E14),
    chartProtein: Color(0xFF00A39A),
    chartCarbs: Color(0xFF007AFF),
    chartFat: Color(0xFF6750A4),
    chartSnack: Color(0xFFE07A2F),
  );

  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color velocityBlue;
  final Color enduranceCyan;
  final Color ghostBorder;
  final Color chartProtein;
  final Color chartCarbs;
  final Color chartFat;
  final Color chartSnack;

  LinearGradient get primaryGradient => LinearGradient(
        colors: [velocityBlue, enduranceCyan],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return this;
  }
}
