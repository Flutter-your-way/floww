import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/nutrition/macro_value_label.dart';
import 'package:floww/core/nutrition/widgets/macro_segment_bar.dart';

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
    final titleStyle = context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Goal', style: titleStyle),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Calories', style: titleStyle),
              const Spacer(),
              Text(
                calories,
                style: context.textTheme.displaySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'kcal',
                style: context.textTheme.bodyMedium?.copyWith(
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
              Expanded(
                child: MacroValueLabel(label: 'Carbs', value: carbs),
              ),
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
