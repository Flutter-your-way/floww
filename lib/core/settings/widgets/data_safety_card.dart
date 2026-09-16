import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class DataSafetyCard extends StatelessWidget {
  const DataSafetyCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: AppSizes.s20,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLargeSemiBold.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
