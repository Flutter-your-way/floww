import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveDietPlanCard extends StatelessWidget {
  const WaveDietPlanCard({
    super.key,
    required this.plan,
    required this.onViewInNutrition,
  });

  final WaveDietPlan plan;
  final VoidCallback onViewInNutrition;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: AppSizes.s18,
                color: context.colors.textPrimary,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(plan.title, style: AppTypography.bodyLargeBold),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            plan.description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSubtle,
            ),
          ),
        ],
      ),
      sections: [
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: WaveSectionLabel(label: 'DAY 1 PREVIEW'),
              ),
              for (final meal in plan.meals) ...[
                SizedBox(height: AppSpacing.lg),
                _DietMealRow(meal: meal),
              ],
            ],
          ),
        ),
        WaveCardSection(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ),
              Text(
                '${NumberFormatter.grouped(plan.totalCalories)} kcal',
                style: AppTypography.bodyMediumBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
        WaveCardSection(
          child: PillButton(
            variant: PillButtonVariant.neutral,
            label: 'View in Nutrition',
            height: AppSizes.s44,
            labelStyle: AppTypography.bodyMediumBold,
            labelColor: context.colors.primary,
            onPressed: onViewInNutrition,
          ),
        ),
      ],
    );
  }
}

class _DietMealRow extends StatelessWidget {
  const _DietMealRow({required this.meal});

  final WaveDietMeal meal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(meal.emoji, style: AppTypography.bodyMediumMedium),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            meal.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          '${meal.calories} kcal',
          style: AppTypography.bodySmallSemiBold.copyWith(
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }
}
