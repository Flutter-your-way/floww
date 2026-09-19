import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/nutrition/macro_segment_bar.dart';
import 'package:floww/config/widgets/nutrition/macro_value_label.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key, required this.nutrition, this.onTap});

  final NutritionSummary nutrition;
  final VoidCallback? onTap;

  bool get _hasData => nutrition.totalCalories > 0;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: 'Nutrition Summary',
            showChevron: true,
            onTap: onTap,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Total Calories',
                style: AppTypography.heading4Medium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${nutrition.totalCalories}',
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: _hasData
                      ? context.colors.primary
                      : context.colors.textPrimary,
                ),
              ),
              Text(
                ' / ${nutrition.calorieGoal} kcal',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          MacroSegmentBar(hasData: _hasData),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: MacroValueLabel(
                  label: 'Protein',
                  value: '${nutrition.proteinG}g',
                ),
              ),
              Expanded(
                child: MacroValueLabel(
                  label: 'Carbs',
                  value: '${nutrition.carbsG}g',
                ),
              ),
              Expanded(
                child: MacroValueLabel(
                  label: 'Fats',
                  value: '${nutrition.fatsG}g',
                ),
              ),
            ],
          ),
          if (!_hasData) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              'Log meals in Nutrition tab to see your data here →',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
