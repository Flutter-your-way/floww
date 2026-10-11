import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class WaveEmojiTile extends StatelessWidget {
  const WaveEmojiTile({
    super.key,
    required this.emoji,
    this.size = AppSizes.s44,
    this.radius = AppRadius.md,
    this.backgroundColor,
    this.borderColor,
  }) : iconAsset = null,
       iconColor = null;

  const WaveEmojiTile.icon({
    super.key,
    required String this.iconAsset,
    required Color this.iconColor,
    this.size = AppSizes.s44,
    this.radius = AppRadius.md,
    this.backgroundColor,
    this.borderColor,
  }) : emoji = '';

  final String emoji;
  final String? iconAsset;
  final Color? iconColor;
  final double size;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;

  static const double _iconScale = 0.55;

  @override
  Widget build(BuildContext context) {
    final iconAsset = this.iconAsset;

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: backgroundColor ?? context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: borderColor ?? context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: iconAsset == null
          ? Text(emoji, style: AppTypography.bodyLargeMedium)
          : SvgPicture.asset(
              iconAsset,
              width: size * _iconScale,
              height: size * _iconScale,
              theme: SvgTheme(
                currentColor: iconColor ?? context.colors.primary,
              ),
            ),
    );
  }
}
