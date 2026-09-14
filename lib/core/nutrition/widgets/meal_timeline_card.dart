import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MealTimelineCard extends StatelessWidget {
  const MealTimelineCard({
    super.key,
    required this.entries,
    required this.onSelect,
  });

  final List<MealTimelineEntry> entries;
  final ValueChanged<MealType> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'Meal Timeline'),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (final entry in entries)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(entry.meal),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entry.meal.icon,
                              color: entry.meal.colorOf(context),
                              size: AppSizes.s12,
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            Flexible(
                              child: Text(
                                entry.meal.label,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              entry.caloriesLabel,
                              style: context.textTheme.titleLarge?.copyWith(
                                color: entry.isSelected
                                    ? colors.primary
                                    : colors.textPrimary,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            Text(
                              'kcal',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
