import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class PremiumPaymentMethodCard extends StatelessWidget {
  const PremiumPaymentMethodCard({
    super.key,
    required this.title,
    required this.methodLabel,
    required this.expiryLabel,
    required this.actionLabel,
    this.onUpdate,
  });

  static const IconData cardIcon = Icons.credit_card_rounded;

  final String title;
  final String methodLabel;
  final String expiryLabel;
  final String actionLabel;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: AppTypography.heading3Bold),
          Divider(
            height: AppSpacing.xl2,
            thickness: AppSizes.s1,
            color: colors.borderSubtle,
          ),
          Row(
            children: [
              const AppIconTile(icon: cardIcon),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLargeSemiBoldTall,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      expiryLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMediumMedium.copyWith(
                        color: colors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              PillButton(
                variant: PillButtonVariant.accent,
                height: AppSizes.s40,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                label: actionLabel,
                labelStyle: AppTypography.labelMediumSemiBold,
                onPressed: onUpdate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
