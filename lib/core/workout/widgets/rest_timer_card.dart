import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.secondsLabel,
    required this.onSkip,
  });

  static const double _aspectRatio = 1;

  final String secondsLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: AppCard(
        variant: AppCardVariant.sunken,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'REST',
              style: AppTypography.labelLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              secondsLabel,
              style: AppTypography.displayNumeric.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'seconds',
              style: AppTypography.labelLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xl4),
            PillButton(
              label: 'Skip Rest',
              width: AppSizes.s160,
              onPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}
