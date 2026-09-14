import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/macro_split_bar.dart';
import 'package:floww/core/nutrition/widgets/meal_type_badge.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MealSummaryCard extends StatelessWidget {
  const MealSummaryCard({
    super.key,
    required this.meal,
    required this.timeLabel,
    required this.caloriesLabel,
    required this.shares,
  });

  final MealType meal;
  final String timeLabel;
  final String caloriesLabel;
  final List<MacroShare> shares;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MealTypeBadge(meal: meal, size: AppSizes.s48),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.label, style: context.textTheme.headlineSmall),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      timeLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    caloriesLabel,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text('kcal', style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          MacroSplitBar(shares: shares, height: AppSizes.s10),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final item in shares)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.macro.label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: item.macro.colorOf(context),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            item.amountLabel,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(item.shareLabel, style: captionStyle),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
