import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:smooth_corner/smooth_corner.dart';

class WaveInsightBanner extends StatelessWidget {
  const WaveInsightBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.tinted,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmoothClipRRect(
            smoothness: AppShapes.smoothness,
            borderRadius: BorderRadius.circular(999),
            child: SvgPicture.asset(AppImages.appIconSvg),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Wave Insight: ',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
