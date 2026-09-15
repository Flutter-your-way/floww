import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/nutrition/view_models/meal_details_view_model.dart';
import 'package:floww/core/nutrition/views/log_food_sheet.dart';
import 'package:floww/core/nutrition/widgets/food_items_card.dart';
import 'package:floww/core/nutrition/widgets/meal_summary_card.dart';
import 'package:floww/core/nutrition/widgets/meal_timeline_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MealDetailsView extends StatelessWidget {
  const MealDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealDetailsViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: 'Meal Details',
          onBack: () => NavigationService.instance.pop(),
          children: [
            MealSummaryCard(
              meal: viewModel.meal,
              timeLabel: viewModel.timeLabel,
              caloriesLabel: viewModel.caloriesLabel,
              shares: viewModel.shares,
            ),
            SizedBox(height: AppSpacing.lg),
            FoodItemsCard(
              items: viewModel.items,
              countLabel: viewModel.itemCountLabel,
              emptyMessage: 'No foods logged for this meal yet.',
              onDelete: viewModel.canEdit ? viewModel.deleteItem : null,
              onAdd: viewModel.canEdit
                  ? () => LogFoodSheet.show(
                      context,
                      date: viewModel.date,
                      meal: viewModel.meal,
                    )
                  : null,
            ),
            if (errorMessage != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                errorMessage,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.destructiveBorder,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.lg),
            TipCard(
              title: 'Nutrition Insight',
              message: viewModel.insightMessage,
              icon: Icons.graphic_eq_rounded,
            ),
            SizedBox(height: AppSpacing.lg),
            MealTimelineCard(
              entries: viewModel.timeline,
              onSelect: viewModel.selectMeal,
            ),
          ],
        );
      },
    );
  }
}
