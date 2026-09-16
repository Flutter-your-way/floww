import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class PremiumRenewalCard extends StatelessWidget {
  const PremiumRenewalCard({
    super.key,
    required this.renewalLabel,
    required this.cancelLabel,
    this.onCancel,
  });

  final String renewalLabel;
  final String cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            renewalLabel,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLargeMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          PressScale(
            onTap: onCancel,
            child: Text(
              cancelLabel,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLargeSemiBold.copyWith(
                color: colors.destructiveBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
