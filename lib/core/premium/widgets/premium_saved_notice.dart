import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class PremiumSavedNotice extends StatelessWidget {
  const PremiumSavedNotice({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: AppSizes.s20,
            color: colors.primary,
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
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close_rounded,
              size: AppSizes.s18,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
