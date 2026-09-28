import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/log_food_view_model.dart';
import 'package:floww/core/nutrition/views/create_food_sheet.dart';
import 'package:floww/core/nutrition/views/food_portion_sheet.dart';
import 'package:floww/core/nutrition/views/food_scan_result_sheet.dart';
import 'package:floww/core/nutrition/widgets/catalog_food_row.dart';
import 'package:floww/core/nutrition/widgets/food_search_status.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class LogFoodSheet extends StatelessWidget {
  const LogFoodSheet({super.key, this.query = ''});

  final String query;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required MealType meal,
    String query = '',
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            LogFoodViewModel(NutritionLogService(), date, meal, query),
        child: LogFoodSheet(query: query),
      ),
    );
  }

  Future<void> _describe(
    BuildContext context,
    LogFoodViewModel viewModel,
  ) async {
    final result = await viewModel.describe();
    if (result == null || !context.mounted) return;
    await FoodScanResultSheet.show(
      context,
      food: result.food,
      goal: result.goal,
      date: viewModel.date,
      meal: viewModel.meal,
    );
  }

  Future<void> _openPortion(
    BuildContext context,
    LogFoodViewModel viewModel,
    CatalogFood food,
  ) async {
    final result = await FoodPortionSheet.show(
      context,
      food: food,
      meal: viewModel.meal,
      logged: viewModel.loggedEntryOf(food),
    );
    if (result == null) return;
    await viewModel.applyPortion(food, result);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogFoodViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final results = viewModel.results;
        final searchNotice = viewModel.searchNotice;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: 'Log Food',
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CompactTextField(
                  hintText: 'Search foods...',
                  initialText: query,
                  icon: Icons.search_rounded,
                  onChanged: viewModel.search,
                ),
                SizedBox(height: AppSpacing.lg),
                PillButton(
                  variant: PillButtonVariant.neutral,
                  label: 'Create Food',
                  height: AppSizes.s44,
                  labelColor: context.colors.primary,
                  onPressed: () => CreateFoodSheet.show(context),
                ),
                SizedBox(height: AppSpacing.lg),
                AppChipTabs<MealType>(
                  items: viewModel.meals,
                  selected: viewModel.meal,
                  labelOf: (meal) => meal.label,
                  onSelected: viewModel.selectMeal,
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
                if (viewModel.canDescribe || viewModel.isDescribing) ...[
                  SizedBox(height: AppSpacing.lg),
                  PillButton(
                    variant: PillButtonVariant.neutral,
                    label: viewModel.describeLabel,
                    icon: Icons.auto_awesome_rounded,
                    height: AppSizes.s44,
                    labelColor: context.colors.primary,
                    isLoading: viewModel.isDescribing,
                    onPressed: viewModel.canDescribe
                        ? () => _describe(context, viewModel)
                        : null,
                  ),
                ],
                SizedBox(height: AppSpacing.sm),
                if (viewModel.showsEmptyMessage)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl3),
                    child: Text(
                      viewModel.emptyMessage,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                for (var i = 0; i < results.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colors.borderSubtle,
                    ),
                  CatalogFoodRow(
                    name: results[i].displayName,
                    macrosLabel: viewModel.macrosLabelOf(results[i]),
                    caloriesLabel: viewModel.caloriesLabelOf(results[i]),
                    isAdded: viewModel.isAdded(results[i]),
                    isSaving: viewModel.isSaving(results[i]),
                    onTap: () => _openPortion(context, viewModel, results[i]),
                  ),
                ],
                if (viewModel.isSearching)
                  FoodSearchStatus(
                    message: viewModel.searchingLabel,
                    isLoading: true,
                  )
                else if (searchNotice != null)
                  FoodSearchStatus(message: searchNotice),
              ],
            ),
          ),
        );
      },
    );
  }
}
