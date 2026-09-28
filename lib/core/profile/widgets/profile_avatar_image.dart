import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/images/cached_avatar_image.dart';
import 'package:floww/config/widgets/placeholders/app_pulse_placeholder.dart';

class ProfileAvatarImage extends StatelessWidget {
  const ProfileAvatarImage({
    super.key,
    required this.initial,
    this.imageUrl,
    this.imageBytes,
    this.size = AppSizes.s60,
    this.radius = AppRadius.lg,
    this.initialStyle,
  });

  final String initial;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final double radius;
  final TextStyle? initialStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageUrl = this.imageUrl;
    final imageBytes = this.imageBytes;
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: AppShapes.decoration(
        color: colors.bgTinted,
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
      ),
      child: switch ((imageBytes, imageUrl)) {
        (final Uint8List bytes, _) => Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          errorBuilder: (context, error, stackTrace) =>
              _ProfileAvatarInitial(initial: initial, style: initialStyle),
        ),
        (_, final String url) => CachedAvatarImage(
          url: url,
          size: size,
          placeholder: AppPulsePlaceholder(
            child: _ProfileAvatarInitial(initial: initial, style: initialStyle),
          ),
          error: _ProfileAvatarInitial(initial: initial, style: initialStyle),
        ),
        _ => _ProfileAvatarInitial(initial: initial, style: initialStyle),
      },
    );
  }
}

class _ProfileAvatarInitial extends StatelessWidget {
  const _ProfileAvatarInitial({required this.initial, this.style});

  final String initial;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: (style ?? AppTypography.heading2Bold).copyWith(
        color: context.colors.primary,
      ),
    );
  }
}
