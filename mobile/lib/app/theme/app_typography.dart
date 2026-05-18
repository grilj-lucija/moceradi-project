import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.displayLg,
    required this.headlineLg,
    required this.headlineLgMobile,
    required this.titleMd,
    required this.bodyLg,
    required this.bodyMd,
    required this.labelMd,
    required this.metricXl,
  });

  factory AppTypography.fromGoogleFonts(Color onSurface) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    TextStyle s({
      required double size,
      required FontWeight weight,
      required double height,
      double? letterSpacing,
    }) {
      return base.bodyMedium!.copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: onSurface,
      );
    }

    return AppTypography(
      displayLg: s(
        size: 48,
        weight: FontWeight.w700,
        height: 56,
        letterSpacing: -0.96,
      ),
      headlineLg: s(
        size: 32,
        weight: FontWeight.w600,
        height: 40,
        letterSpacing: -0.32,
      ),
      headlineLgMobile: s(
        size: 28,
        weight: FontWeight.w600,
        height: 36,
      ),
      titleMd: s(
        size: 20,
        weight: FontWeight.w600,
        height: 28,
      ),
      bodyLg: s(
        size: 18,
        weight: FontWeight.w400,
        height: 28,
      ),
      bodyMd: s(
        size: 16,
        weight: FontWeight.w400,
        height: 24,
      ),
      labelMd: s(
        size: 14,
        weight: FontWeight.w500,
        height: 20,
        letterSpacing: 0.7,
      ),
      metricXl: s(
        size: 40,
        weight: FontWeight.w700,
        height: 40,
        letterSpacing: -0.8,
      ),
    );
  }

  final TextStyle displayLg;
  final TextStyle headlineLg;
  final TextStyle headlineLgMobile;
  final TextStyle titleMd;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle labelMd;
  final TextStyle metricXl;

  @override
  AppTypography copyWith() => this;

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return this;
  }
}
