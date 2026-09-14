import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/meal_type_badge.dart';

class MealBreakdownCard extends StatelessWidget {
  const MealBreakdownCard({
    super.key,
    required this.items,
    required this.onOpenMeal,
    this.onAddToMeal,
    this.onAddMeal,
  });

  final List<MealBreakdownItem> items;
  final ValueChanged<MealType> onOpenMeal;
  final ValueChanged<MealType>? onAddToMeal;
  final VoidCallback? onAddMeal;

  @override
  Widget build(BuildContext context) {
    final onAddMeal = this.onAddMeal;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(title: 'Meal Breakdown'),
          SizedBox(height: AppSpacing.md),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.borderSubtle,
              ),
            _MealRow(
              item: items[i],
              onOpen: () => onOpenMeal(items[i].meal),
              onAdd: onAddToMeal == null
                  ? null
                  : () => onAddToMeal!(items[i].meal),
            ),
          ],
          if (onAddMeal != null) ...[
            SizedBox(height: AppSpacing.lg),
            PillButton(
              variant: PillButtonVariant.neutral,
              label: 'Add Meal',
              icon: Icons.add_rounded,
              onPressed: onAddMeal,
            ),
          ],
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.item, required this.onOpen, this.onAdd});

  final MealBreakdownItem item;
  final VoidCallback onOpen;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAdd = this.onAdd;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return GestureDetector(
      onTap: item.hasItems ? onOpen : onAdd,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            MealTypeBadge(meal: item.meal),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.meal.label, style: context.textTheme.titleMedium),
                  SizedBox(height: AppSpacing.xs),
                  if (item.hasItems) ...[
                    AppProgressBar(progress: item.share),
                    SizedBox(height: AppSpacing.xs),
                  ],
                  Text(item.subtitle, style: captionStyle),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            if (item.hasItems)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.caloriesLabel, style: context.textTheme.labelMedium),
                  Text(item.shareLabel, style: captionStyle),
                ],
              )
            else if (onAdd != null)
              CircularHeaderButton(
                icon: Icons.add_rounded,
                size: AppSizes.s28,
                iconSize: AppSizes.s16,
                iconColor: colors.primary,
                backgroundColor: colors.tint,
                onPressed: onAdd,
              ),
          ],
        ),
      ),
    );
  }
}
