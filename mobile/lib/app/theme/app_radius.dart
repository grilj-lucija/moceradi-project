import 'package:flutter/material.dart';

@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    this.sm = 4,
    this.base = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.full = 9999,
  });

  final double sm;
  final double base;
  final double md;
  final double lg;
  final double xl;
  final double full;

  BorderRadius get smRadius => BorderRadius.all(Radius.circular(sm));
  BorderRadius get baseRadius => BorderRadius.all(Radius.circular(base));
  BorderRadius get mdRadius => BorderRadius.all(Radius.circular(md));
  BorderRadius get lgRadius => BorderRadius.all(Radius.circular(lg));
  BorderRadius get xlRadius => BorderRadius.all(Radius.circular(xl));
  BorderRadius get pill => BorderRadius.all(Radius.circular(full));

  @override
  AppRadius copyWith() => this;

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return this;
  }
}
