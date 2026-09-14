import 'package:flutter/material.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';
import 'package:floww/core/nutrition/widgets/detected_meal_card.dart';
import 'package:floww/core/nutrition/widgets/food_sheet_actions.dart';

class FoodScanReviewPanel extends StatelessWidget {
  const FoodScanReviewPanel({
    super.key,
    required this.mealName,
    required this.calories,
    required this.dailyGoal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.micronutrients,
    this.isSaving = false,
    this.errorMessage,
    this.onClose,
    this.onEdit,
    this.onSave,
  });

  final String mealName;
  final String calories;
  final String dailyGoal;
  final String protein;
  final String carbs;
  final String fat;
  final List<MicronutrientProgress> micronutrients;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      title: 'AI Food Scan',
      subtitle: 'WAVE analyses your meal photo',
      onClose: isSaving ? null : onClose,
      body: DetectedMealCard(
        mealName: mealName,
        calories: calories,
        dailyGoal: dailyGoal,
        protein: protein,
        carbs: carbs,
        fat: fat,
        micronutrients: micronutrients,
      ),
      footer: FoodSheetActions(
        secondaryLabel: 'Edit Meal',
        secondaryIcon: Icons.edit_outlined,
        onSecondary: onEdit,
        primaryLabel: 'Start Workout',
        primaryIcon: Icons.check_rounded,
        onPrimary: onSave,
        isLoading: isSaving,
        errorMessage: errorMessage,
      ),
    );
  }
}
