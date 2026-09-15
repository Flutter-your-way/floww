import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/log_food_view_model.dart';
import 'package:floww/core/nutrition/widgets/catalog_food_row.dart';
import 'package:floww/core/nutrition/widgets/compact_text_field.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LogFoodViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final results = viewModel.results;

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
                SizedBox(height: AppSpacing.sm),
                if (results.isEmpty)
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
                    onAdd: () => viewModel.add(results[i]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
