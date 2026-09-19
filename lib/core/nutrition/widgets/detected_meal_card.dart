import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';
import 'package:floww/core/nutrition/widgets/micronutrient_progress_list.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/theme/app_shapes.dart';

class DetectedMealCard extends StatelessWidget {
  const DetectedMealCard({
    super.key,
    required this.mealName,
    required this.calories,
    required this.dailyGoal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.micronutrients,
  });

  final String mealName;
  final String calories;
  final String dailyGoal;
  final String protein;
  final String carbs;
  final String fat;
  final List<MicronutrientProgress> micronutrients;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderAccent),
        shadows: [BoxShadow(color: colors.tint, blurRadius: AppSizes.s16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detected Meal',
            style: context.textTheme.bodySmall?.copyWith(color: colors.primary),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(mealName, style: context.textTheme.titleMedium),
          SizedBox(height: AppSpacing.xl),
          _CaloriesSummary(calories: calories, dailyGoal: dailyGoal),
          SizedBox(height: AppSpacing.xl3),
          const SectionLabel(label: 'Macronutrients'),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MacroTile(
                  label: 'Protein',
                  value: protein,
                  color: colors.proteinAccent,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MacroTile(
                  label: 'Carbs',
                  value: carbs,
                  color: colors.carbsAccent,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MacroTile(
                  label: 'Fat',
                  value: fat,
                  color: colors.fatAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl3),
          const SectionLabel(label: 'Micronutrients'),
          MicronutrientProgressList(items: micronutrients),
        ],
      ),
    );
  }
}

class _CaloriesSummary extends StatelessWidget {
  const _CaloriesSummary({required this.calories, required this.dailyGoal});

  final String calories;
  final String dailyGoal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textMuted,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Calories',
                style: context.textTheme.bodyMedium,
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    calories,
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
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Daily Goal', style: captionStyle),
            SizedBox(height: AppSpacing.xs),
            Text(
              dailyGoal,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
