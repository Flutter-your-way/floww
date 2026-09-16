import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class ConnectedAppLogo extends StatelessWidget {
  const ConnectedAppLogo({super.key, this.iconAsset, this.wordmark});

  static const double _wordmarkFontSize = 9;
  static const double _wordmarkLetterSpacing = 0.2;

  final String? iconAsset;
  final String? wordmark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconAsset = this.iconAsset;
    final wordmark = this.wordmark;

    return SmoothClipRRect(
      smoothness: AppShapes.smoothness,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: AppSizes.s44,
        child: iconAsset != null
            ? SvgPicture.asset(iconAsset, fit: BoxFit.cover)
            : ColoredBox(
                color: colors.brandLight,
                child: Center(
                  child: Text(
                    wordmark ?? '',
                    style: AppTypography.bodySmallExtraBold.copyWith(
                      color: colors.onBrandLight,
                      fontSize: _wordmarkFontSize,
                      letterSpacing: _wordmarkLetterSpacing,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
