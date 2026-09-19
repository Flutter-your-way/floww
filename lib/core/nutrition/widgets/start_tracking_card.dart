import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class StartTrackingCard extends StatelessWidget {
  const StartTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.highlighted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.waving_hand_rounded,
            color: context.colors.accentOrange,
            size: AppSizes.s24,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Tracking Today',
                  style: AppTypography.heading4SemiBold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Log your meals below to track calories, macros, and build '
                  'your nutrition score.',
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
