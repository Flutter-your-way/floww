import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/models/nutrient_input.dart';
import 'package:floww/core/nutrition/widgets/food_sheet_actions.dart';
import 'package:floww/core/nutrition/widgets/meal_name_field.dart';
import 'package:floww/core/nutrition/widgets/nutrient_input_grid.dart';
import 'package:floww/config/widgets/headers/section_label.dart';

class FoodMealEditPanel extends StatelessWidget {
  const FoodMealEditPanel({
    super.key,
    required this.mealName,
    required this.macroInputs,
    required this.microInputs,
    required this.onNameChanged,
    required this.onNutrientChanged,
    this.isSaving = false,
    this.errorMessage,
    this.onClose,
    this.onBack,
    this.onSave,
  });

  final String mealName;
  final List<NutrientInput> macroInputs;
  final List<NutrientInput> microInputs;
  final ValueChanged<String> onNameChanged;
  final void Function(FoodNutrient nutrient, String value) onNutrientChanged;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      title: 'Edit Nutrients',
      subtitle: 'Adjust values before saving',
      onClose: isSaving ? null : onClose,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(label: 'Meal name'),
          SizedBox(height: AppSpacing.md),
          MealNameField(initialValue: mealName, onChanged: onNameChanged),
          SizedBox(height: AppSpacing.xl3),
          const SectionLabel(label: 'Macronutrients'),
          SizedBox(height: AppSpacing.md),
          NutrientInputGrid(
            inputs: macroInputs,
            highlighted: true,
            onChanged: onNutrientChanged,
          ),
          SizedBox(height: AppSpacing.xl3),
          const SectionLabel(label: 'Micronutrients'),
          SizedBox(height: AppSpacing.md),
          NutrientInputGrid(
            inputs: microInputs,
            onChanged: onNutrientChanged,
          ),
        ],
      ),
      footer: FoodSheetActions(
        secondaryLabel: 'Back',
        secondaryIcon: Icons.chevron_left_rounded,
        onSecondary: onBack,
        primaryLabel: 'Add to Log',
        primaryIcon: Icons.check_rounded,
        onPrimary: onSave,
        isLoading: isSaving,
        errorMessage: errorMessage,
      ),
    );
  }
}
