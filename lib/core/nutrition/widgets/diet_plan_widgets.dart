import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/config/theme/app_shapes.dart';

class DietPlanProgressCard extends StatelessWidget {
  const DietPlanProgressCard({
    super.key,
    required this.progressLabel,
    required this.percentLabel,
    required this.progress,
    required this.startLabel,
    required this.endLabel,
  });

  final String progressLabel;
  final String percentLabel;
  final double progress;
  final String startLabel;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progressLabel,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                percentLabel,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppProgressBar(progress: progress, height: AppSizes.s8),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(child: Text(startLabel, style: captionStyle)),
              Text(endLabel, style: captionStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class DietPlanDayCard extends StatelessWidget {
  const DietPlanDayCard({super.key, required this.day, required this.onTap});

  final DietPlanDayItem day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );
    final divider = Divider(height: 1, thickness: 1, color: colors.borderSubtle);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: day.isToday || day.isExpanded
            ? AppCardVariant.highlighted
            : AppCardVariant.plain,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  alignment: Alignment.center,
                  decoration: AppShapes.decoration(
                    color: colors.backgroundElevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    side: BorderSide(
                      color: day.isCompleted
                          ? colors.borderAccent
                          : colors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    '${day.dayNumber}',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: day.isCompleted
                          ? colors.primary
                          : colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.title, style: context.textTheme.titleMedium),
                      Text(day.caloriesLabel, style: captionStyle),
                    ],
                  ),
                ),
                Icon(
                  day.isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: day.isCompleted ? colors.primary : colors.textSecondary,
                  size: AppSizes.s20,
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(
                  day.isExpanded
                      ? Icons.expand_more_rounded
                      : Icons.chevron_right_rounded,
                  color: colors.textSecondary,
                  size: AppSizes.s20,
                ),
              ],
            ),
            if (day.isExpanded) ...[
              SizedBox(height: AppSpacing.md),
              divider,
              for (final meal in day.meals) _PlanMealRow(meal: meal),
              divider,
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: Text('Daily totals', style: captionStyle)),
                  _TotalLabel(label: 'Protein', value: day.proteinLabel),
                  SizedBox(width: AppSpacing.md),
                  _TotalLabel(label: 'Carbs', value: day.carbsLabel),
                  SizedBox(width: AppSpacing.md),
                  _TotalLabel(label: 'Fat', value: day.fatLabel),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanMealRow extends StatelessWidget {
  const _PlanMealRow({required this.meal});

  final DietPlanMealItem meal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            meal.meal.icon,
            color: meal.meal.colorOf(context),
            size: AppSizes.s20,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: context.textTheme.bodySmall),
                Text(
                  meal.macrosLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            meal.caloriesLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label ',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.textSecondary,
        ),
        children: [
          TextSpan(text: value, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}
