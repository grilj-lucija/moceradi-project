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
