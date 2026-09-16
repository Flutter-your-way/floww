import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';

class PremiumPriceCard extends StatelessWidget {
  const PremiumPriceCard({
    super.key,
    required this.priceLabel,
    required this.periodLabel,
    this.highlightLabel,
    this.savingsLabel,
  });

  final String priceLabel;
  final String periodLabel;
  final String? highlightLabel;
  final String? savingsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlightLabel = this.highlightLabel;
    final savingsLabel = this.savingsLabel;

    return AppCard(
      variant: AppCardVariant.glow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (highlightLabel != null) ...[
            AppStatusChip(
              label: highlightLabel,
              labelStyle: AppTypography.bodySmallSemiBold,
              isExpanded: true,
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          Text(priceLabel, style: AppTypography.bodyXXLargeBold),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                periodLabel,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textSubtle,
                ),
              ),
              if (savingsLabel != null) ...[
                SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    savingsLabel,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLargeMedium.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
