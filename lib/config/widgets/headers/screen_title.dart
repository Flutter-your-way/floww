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
    this.scaleTitleToFit = false,
  });

  final String eyebrow;
  final String title;
  final DateChangeDirection? eyebrowDirection;
  final bool scaleTitleToFit;

  @override
  Widget build(BuildContext context) {
    final direction = eyebrowDirection;
    final titleText = Text(
      title,
      maxLines: AppLimits.displayNameMaxLines,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.heading3ExtraBoldItalic.copyWith(
        color: context.colors.textPrimary,
      ),
    );
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
        if (scaleTitleToFit)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: titleText,
          )
        else
          titleText,
      ],
    );
  }
}
