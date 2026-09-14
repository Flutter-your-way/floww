import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';

class NutritionEmptyStateCard extends StatelessWidget {
  const NutritionEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.s64,
            height: AppSizes.s64,
            decoration: AppShapes.decoration(
              color: context.colors.backgroundElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: context.colors.borderSubtle),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: context.colors.textSecondary,
              size: AppSizes.s28,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.headlineSmall),
                SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
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
