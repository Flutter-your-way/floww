import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_constants.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow,
          style: AppTypography.heading4SemiBold.copyWith(
            color: context.colors.backgroundSecondary,
          ),
        ),
        Text(
          title,
          maxLines: AppLimits.displayNameMaxLines,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.heading3ExtraBoldItalic.copyWith(
            color: context.colors.backgroundSecondary,
          ),
        ),
      ],
    );
  }
}
