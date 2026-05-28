import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_colors.dart';
import 'package:health_app/app/theme/app_theme.dart';

const Duration _kPulseDuration = Duration(milliseconds: 1200);
const double _kMinOpacity = 0.55;
const double _kMaxOpacity = 1;

class SkeletonGroup extends StatefulWidget {
  const SkeletonGroup({required this.child, super.key});

  final Widget child;

  @override
  State<SkeletonGroup> createState() => _SkeletonGroupState();
}

class _SkeletonGroupState extends State<SkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kPulseDuration,
    );
    unawaited(_controller.repeat(reverse: true));
    _opacity = Tween<double>(begin: _kMinOpacity, end: _kMaxOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonScope(
      animation: _opacity,
      child: widget.child,
    );
  }
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  static Animation<double>? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();
    return scope?.animation;
  }

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) =>
      oldWidget.animation != animation;
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height,
    this.radius,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  const SkeletonBox.circle({
    required double size,
    Key? key,
  }) : this(
          width: size,
          height: size,
          shape: BoxShape.circle,
          key: key,
        );

  final double? width;
  final double? height;
  final BorderRadius? radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final br = shape == BoxShape.circle
        ? null
        : (radius ?? context.radius.baseRadius);

    final groupAnimation = _SkeletonScope.maybeOf(context);
    if (groupAnimation != null) {
      return AnimatedBuilder(
        animation: groupAnimation,
        builder: (_, _) => _paint(colors, br, groupAnimation.value),
      );
    }
    return _StandaloneSkeleton(
      builder: (value) => _paint(colors, br, value),
    );
  }

  Widget _paint(AppColors colors, BorderRadius? br, double value) {
    final base = colors.surfaceContainerLow;
    final highlight = colors.surfaceContainerHigh;
    final blended = Color.lerp(base, highlight, value)!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: blended,
        borderRadius: br,
        shape: shape,
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox.circle(size: size);
  }
}

class SkeletonBone extends StatelessWidget {
  const SkeletonBone({
    required this.width,
    this.height = 14,
    this.radius,
    super.key,
  });

  const SkeletonBone.pill({
    required this.width,
    this.height = 12,
    super.key,
  }) : radius = const BorderRadius.all(Radius.circular(999));

  final double width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      radius: radius ?? const BorderRadius.all(Radius.circular(6)),
    );
  }
}

class _StandaloneSkeleton extends StatefulWidget {
  const _StandaloneSkeleton({required this.builder});

  final Widget Function(double value) builder;

  @override
  State<_StandaloneSkeleton> createState() => _StandaloneSkeletonState();
}

class _StandaloneSkeletonState extends State<_StandaloneSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kPulseDuration,
    );
    unawaited(_controller.repeat(reverse: true));
    _opacity = Tween<double>(begin: _kMinOpacity, end: _kMaxOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, _) => widget.builder(_opacity.value),
    );
  }
}
