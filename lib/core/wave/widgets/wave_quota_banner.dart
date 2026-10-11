import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';

class WaveQuotaBanner extends StatelessWidget {
  const WaveQuotaBanner({
    super.key,
    required this.message,
    required this.upsell,
    required this.actionLabel,
    required this.onUpgrade,
  });

  final String message;
  final String upsell;
  final String actionLabel;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = colors.accentViolet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: accent.withValues(alpha: AppOpacity.tintFill),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: accent.withValues(alpha: AppOpacity.tintBorder),
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppTypography.bodySmallSemiBold.copyWith(
                    color: accent,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  upsell,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          PillButton(
            variant: PillButtonVariant.neutral,
            label: actionLabel,
            height: AppSizes.s36,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            labelStyle: AppTypography.bodySmallSemiBold,
            labelColor: accent,
            onPressed: onUpgrade,
          ),
        ],
      ),
    );
  }
}
