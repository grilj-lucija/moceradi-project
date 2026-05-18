import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_app/app/theme/app_colors.dart';
import 'package:health_app/app/theme/app_radius.dart';
import 'package:health_app/app/theme/app_spacing.dart';
import 'package:health_app/app/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    const colors = AppColors.dark;
    final typography = AppTypography.fromGoogleFonts(colors.onSurface);
    const spacing = AppSpacing();
    const radius = AppRadius();

    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerLowest: colors.surfaceContainerLowest,
      surfaceContainerLow: colors.surfaceContainerLow,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceContainerHigh,
      surfaceContainerHighest: colors.surfaceContainerHighest,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
    );

    final textTheme = TextTheme(
      displayLarge: typography.displayLg,
      headlineLarge: typography.headlineLg,
      headlineMedium: typography.headlineLgMobile,
      titleMedium: typography.titleMd,
      bodyLarge: typography.bodyLg,
      bodyMedium: typography.bodyMd,
      labelLarge: typography.labelMd,
      labelMedium: typography.labelMd,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colors.onSurface, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: typography.titleMd,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius.xlRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        hintStyle: typography.bodyMd.copyWith(color: colors.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: radius.baseRadius,
          borderSide: BorderSide(color: colors.ghostBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius.baseRadius,
          borderSide: BorderSide(color: colors.ghostBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius.baseRadius,
          borderSide: BorderSide(color: colors.enduranceCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius.baseRadius,
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        contentTextStyle: typography.bodyMd,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius.mdRadius),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.enduranceCyan,
        linearTrackColor: colors.surfaceContainerHigh,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors.dark,
        typography,
        spacing,
        radius,
      ],
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;
}
