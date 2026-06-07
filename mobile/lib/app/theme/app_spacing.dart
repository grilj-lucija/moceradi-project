import 'package:flutter/material.dart';

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.base = 8,
    this.containerMarginMobile = 16,
    this.containerMarginDesktop = 48,
    this.gutter = 16,
    this.stackSm = 8,
    this.stackMd = 16,
    this.stackLg = 24,
    this.sectionGap = 40,
    this.touchTargetMin = 48,
  });

  final double base;
  final double containerMarginMobile;
  final double containerMarginDesktop;
  final double gutter;
  final double stackSm;
  final double stackMd;
  final double stackLg;
  final double sectionGap;
  final double touchTargetMin;

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: containerMarginMobile,
        vertical: stackLg,
      );

  EdgeInsets get cardPadding => EdgeInsets.all(stackLg);

  @override
  AppSpacing copyWith() => this;

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return this;
  }
}
