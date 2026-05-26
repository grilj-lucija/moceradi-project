import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:health_app/app/theme/app_theme.dart';

enum ProfileAvatarSize { sm, md, lg, xl }

extension ProfileAvatarSizeX on ProfileAvatarSize {
  double get diameter => switch (this) {
        ProfileAvatarSize.sm => 40,
        ProfileAvatarSize.md => 56,
        ProfileAvatarSize.lg => 96,
        ProfileAvatarSize.xl => 120,
      };
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    this.avatarUrl,
    this.size = ProfileAvatarSize.md,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
    this.preview,
    super.key,
  });

  final String name;
  final String? avatarUrl;
  final ProfileAvatarSize size;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Uint8List? preview;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    final a = parts.first.characters.first;
    final b = parts.last.characters.first;
    return '$a$b'.toUpperCase();
  }

  ImageProvider? _resolveImage() {
    if (preview != null) return MemoryImage(preview!);
    final url = avatarUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex == -1) return null;
      try {
        final bytes = base64Decode(url.substring(commaIndex + 1));
        return MemoryImage(bytes);
      } on FormatException {
        return null;
      }
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    final diameter = size.diameter;
    final image = _resolveImage();
    final initials = _initials();

    final initialsStyle = switch (size) {
      ProfileAvatarSize.sm => typography.labelMd.copyWith(
          color: colors.enduranceCyan,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ProfileAvatarSize.md => typography.titleMd.copyWith(
          color: colors.enduranceCyan,
          fontWeight: FontWeight.w700,
        ),
      ProfileAvatarSize.lg ||
      ProfileAvatarSize.xl =>
        typography.headlineLgMobile.copyWith(
          color: colors.enduranceCyan,
          fontWeight: FontWeight.w700,
        ),
    };

    final border = borderColor ?? colors.ghostBorder;

    final content = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: radius.pill,
        border: Border.all(color: border, width: borderWidth),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(initials, style: initialsStyle)
          : null,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius.pill,
        child: content,
      ),
    );
  }
}
