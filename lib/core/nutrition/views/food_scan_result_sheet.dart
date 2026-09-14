import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/food_scan_result_view_model.dart';
import 'package:floww/core/nutrition/widgets/food_meal_edit_panel.dart';
import 'package:floww/core/nutrition/widgets/food_scan_review_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FoodScanResultSheet extends StatelessWidget {
  const FoodScanResultSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required FoodModel food,
    required NutritionGoal goal,
    required DateTime date,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            FoodScanResultViewModel(food, goal, NutritionLogService(), date),
        child: const FoodScanResultSheet(),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    FoodScanResultViewModel viewModel,
  ) async {
    final saved = await viewModel.addToLog();
    if (!saved || !context.mounted) return;
    HapticManager.success();
    NavigationService.instance.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodScanResultViewModel>(
      builder: (context, viewModel, child) {
        final onSave = viewModel.canSave
            ? () => _save(context, viewModel)
            : null;

        return PopScope(
          canPop: !viewModel.isSaving && !viewModel.isEditing,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && viewModel.isEditing && !viewModel.isSaving) {
              viewModel.finishEditing();
            }
          },
          child: AppFloatingSheet(
            child: viewModel.isEditing
                ? FoodMealEditPanel(
                    key: const ValueKey(FoodMealEditPanel),
                    mealName: viewModel.draftName,
                    macroInputs: viewModel.macroInputs,
                    microInputs: viewModel.microInputs,
                    onNameChanged: viewModel.updateName,
                    onNutrientChanged: viewModel.updateNutrient,
                    isSaving: viewModel.isSaving,
                    errorMessage: viewModel.errorMessage,
                    onClose: () => NavigationService.instance.pop(),
                    onBack: viewModel.finishEditing,
                    onSave: onSave,
                  )
                : FoodScanReviewPanel(
                    key: const ValueKey(FoodScanReviewPanel),
                    mealName: viewModel.mealName,
                    calories: viewModel.caloriesLabel,
                    dailyGoal: viewModel.dailyGoalLabel,
                    protein: viewModel.proteinLabel,
                    carbs: viewModel.carbsLabel,
                    fat: viewModel.fatLabel,
                    micronutrients: viewModel.micronutrients,
                    isSaving: viewModel.isSaving,
                    errorMessage: viewModel.errorMessage,
                    onClose: () => NavigationService.instance.pop(),
                    onEdit: viewModel.startEditing,
                    onSave: onSave,
                  ),
          ),
        );
      },
    );
  }
}
