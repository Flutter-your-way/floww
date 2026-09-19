import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class PremiumPaymentsSummaryCard extends StatelessWidget {
  const PremiumPaymentsSummaryCard({
    super.key,
    required this.totalLabel,
    required this.totalCaption,
    required this.countLabel,
    required this.sinceLabel,
  });

  final String totalLabel;
  final String totalCaption;
  final String countLabel;
  final String sinceLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.glow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyHeadlineBoldTight,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  totalCaption,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                countLabel,
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: colors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                sinceLabel,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
