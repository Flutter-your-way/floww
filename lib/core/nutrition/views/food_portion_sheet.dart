import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/views/food_photo_sheet.dart';
import 'package:floww/core/nutrition/widgets/food_photo.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_portion_result.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/view_models/food_portion_view_model.dart';
import 'package:floww/core/nutrition/widgets/food_sheet_actions.dart';
import 'package:floww/core/nutrition/widgets/portion_nutrition_summary.dart';
import 'package:floww/core/nutrition/widgets/portion_picker.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FoodPortionSheet extends StatelessWidget {
  const FoodPortionSheet({super.key});

  static Future<FoodPortionResult?> show(
    BuildContext context, {
    required CatalogFood food,
    required MealType meal,
    FoodLog? logged,
  }) {
    return showAppFloatingSheet<FoodPortionResult>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            FoodPortionViewModel(food: food, meal: meal, logged: logged),
        child: const FoodPortionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodPortionViewModel>(
      builder: (context, viewModel, child) {
        final result = viewModel.result;
        final onSave = result == null
            ? null
            : () => NavigationService.instance.pop(result);

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            leading: FoodPhoto(
              name: viewModel.title,
              size: AppSizes.s48,
              onTap: () => FoodPhotoSheet.show(context, viewModel.title),
            ),
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                PortionPicker(
                  portion: viewModel.portion,
                  onUnitSelected: viewModel.selectUnit,
                  onAmountChanged: viewModel.updateAmount,
                  onPresetSelected: viewModel.selectPreset,
                  onIncrement: viewModel.increment,
                  onDecrement: viewModel.decrement,
                ),
                SizedBox(height: AppSpacing.xl),
                PortionNutritionSummary(
                  caloriesLabel: viewModel.caloriesLabel,
                  proteinLabel: viewModel.proteinLabel,
                  carbsLabel: viewModel.carbsLabel,
                  fatLabel: viewModel.fatLabel,
                  microsLabel: viewModel.microsLabel,
                ),
              ],
            ),
            footer: viewModel.isEditing
                ? FoodSheetActions(
                    secondaryLabel: 'Remove',
                    secondaryIcon: Icons.delete_outline_rounded,
                    primaryLabel: viewModel.primaryLabel,
                    primaryIcon: Icons.check_rounded,
                    onSecondary: () => NavigationService.instance.pop(
                      const FoodPortionResult.remove(),
                    ),
                    onPrimary: onSave,
                  )
                : PillButton(
                    label: viewModel.primaryLabel,
                    icon: Icons.add_rounded,
                    height: AppSizes.s48,
                    onPressed: onSave,
                  ),
          ),
        );
      },
    );
  }
}
