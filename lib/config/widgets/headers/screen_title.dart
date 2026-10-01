import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_constants.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.eyebrowDirection,
  });

  final String eyebrow;
  final String title;
  final DateChangeDirection? eyebrowDirection;

  @override
  Widget build(BuildContext context) {
    final direction = eyebrowDirection;
    final eyebrowText = Text(
      eyebrow,
      style: AppTypography.heading4SemiBold.copyWith(
        color: context.colors.textPrimary,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (direction == null)
          eyebrowText
        else
          DateChangeTransition(
            value: eyebrow,
            direction: direction,
            duration: AppMotion.fast,
            distance: AppMotion.slideDistanceSmall,
            child: eyebrowText,
          ),
        Text(
          title,
          maxLines: AppLimits.displayNameMaxLines,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.heading3ExtraBoldItalic.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
