import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class AppErrorCard extends StatelessWidget {
  const AppErrorCard({
    super.key,
    required this.message,
    this.retryLabel = 'Try Again',
    this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onRetry = this.onRetry;

    return AppCard(
      borderColor: colors.destructiveBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppSizes.s20,
                color: colors.destructive,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppSpacing.xl),
            PillButton(
              variant: PillButtonVariant.neutral,
              label: retryLabel,
              height: AppSizes.s40,
              labelStyle: AppTypography.labelMediumSemiBold,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
