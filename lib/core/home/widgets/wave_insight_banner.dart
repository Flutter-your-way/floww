import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class WaveInsightBanner extends StatelessWidget {
  const WaveInsightBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.accentOutline,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppImages.waveIcon,
            width: AppSizes.s36,
            height: AppSizes.s36,
            theme: SvgTheme(currentColor: context.colors.primary),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: 'Wave Insight: ',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
