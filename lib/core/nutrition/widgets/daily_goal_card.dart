import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/nutrition/macro_segment_bar.dart';
import 'package:floww/config/widgets/nutrition/macro_value_label.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final String calories;
  final String protein;
  final String carbs;
  final String fats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Goal',
            style: AppTypography.heading4SemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Calories',
                style: AppTypography.labelLargeMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                calories,
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: context.colors.primaryAlt,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'kcal',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          const MacroSegmentBar(),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MacroValueLabel(label: 'Protein', value: protein),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: MacroValueLabel(label: 'Carbs', value: carbs),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: MacroValueLabel(label: 'Fats', value: fats),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
