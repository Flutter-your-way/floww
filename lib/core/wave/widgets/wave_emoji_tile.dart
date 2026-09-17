import 'package:flutter/material.dart';

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
  });

  final String emoji;
  final double size;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
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
      child: Text(emoji, style: AppTypography.bodyLargeMedium),
    );
  }
}
