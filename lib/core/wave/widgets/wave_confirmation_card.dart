import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';
import 'package:floww/core/wave/widgets/wave_emoji_tile.dart';

class WaveConfirmationCard extends StatelessWidget {
  const WaveConfirmationCard({
    super.key,
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      sections: [
        WaveCardSection(
          child: Row(
            children: [
              WaveEmojiTile(
                emoji: '✅',
                size: AppSizes.s40,
                backgroundColor: context.colors.success.withValues(
                  alpha: AppOpacity.tintFill,
                ),
                borderColor: context.colors.success.withValues(
                  alpha: AppOpacity.tintBorder,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMediumBold.copyWith(
                        color: context.colors.success,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      detail,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
