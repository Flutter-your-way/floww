import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';
import 'package:floww/core/wave/widgets/wave_emoji_tile.dart';

class WaveConfirmationCard extends StatelessWidget {
  const WaveConfirmationCard({
    super.key,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;

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
              if (actionLabel != null) ...[
                SizedBox(width: AppSpacing.md),
                PillButton(
                  variant: PillButtonVariant.neutral,
                  label: actionLabel,
                  height: AppSizes.s36,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  labelStyle: AppTypography.bodySmallSemiBold,
                  labelColor: context.colors.primary,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
