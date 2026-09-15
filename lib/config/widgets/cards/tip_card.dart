import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class NutritionTipCard extends StatelessWidget {
  const NutritionTipCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.tinted,
      child: Row(
        children: [
          Container(
            width: AppSizes.s32,
            height: AppSizes.s32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: context.gradients.bright,
            ),
            child: Icon(
              icon,
              color: context.colors.backgroundPrimary,
              size: AppSizes.s20,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(message, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
