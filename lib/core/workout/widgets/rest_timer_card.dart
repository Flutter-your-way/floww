import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.secondsLabel,
    required this.onSkip,
    required this.onAdjust,
    required this.canShorten,
    this.nextUpLabel,
  });

  static const double _aspectRatio = 1;
  static const double _adjustButtonSize = AppSizes.s44;

  final String secondsLabel;
  final VoidCallback onSkip;
  final ValueChanged<int> onAdjust;
  final bool canShorten;
  final String? nextUpLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextUpLabel = this.nextUpLabel;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularHeaderButton(
                  icon: Icons.remove_rounded,
                  size: _adjustButtonSize,
                  iconColor: colors.textSecondary,
                  backgroundColor: colors.surfaceTranslucent,
                  borderColor: colors.borderMedium,
                  onPressed: canShorten ? () => onAdjust(-1) : null,
                ),
                SizedBox(width: AppSpacing.xl3),
                Text(
                  secondsLabel,
                  style: AppTypography.displayNumeric.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(width: AppSpacing.xl3),
                CircularHeaderButton(
                  icon: Icons.add_rounded,
                  size: _adjustButtonSize,
                  iconColor: colors.textSecondary,
                  backgroundColor: colors.surfaceTranslucent,
                  borderColor: colors.borderMedium,
                  onPressed: () => onAdjust(1),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'seconds',
              style: AppTypography.labelLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (nextUpLabel != null) ...[
              SizedBox(height: AppSpacing.xl),
              Text(
                nextUpLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl3),
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
