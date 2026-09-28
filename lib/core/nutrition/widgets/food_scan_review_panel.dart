import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';
import 'package:floww/core/nutrition/widgets/detected_meal_card.dart';
import 'package:floww/core/nutrition/widgets/food_sheet_actions.dart';

class FoodScanReviewPanel extends StatelessWidget {
  const FoodScanReviewPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mealName,
    required this.servingLabel,
    required this.portionHint,
    required this.portionPicker,
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

  final String title;
  final String subtitle;
  final String mealName;
  final String servingLabel;
  final String portionHint;
  final Widget portionPicker;
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
      title: title,
      subtitle: subtitle,
      onClose: isSaving ? null : onClose,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel(label: 'How much did you eat?'),
          SizedBox(height: AppSpacing.xs),
          Text(
            portionHint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          portionPicker,
          SizedBox(height: AppSpacing.xl3),
          DetectedMealCard(
            mealName: mealName,
            servingLabel: servingLabel,
            calories: calories,
            dailyGoal: dailyGoal,
            protein: protein,
            carbs: carbs,
            fat: fat,
            micronutrients: micronutrients,
          ),
        ],
      ),
      footer: FoodSheetActions(
        secondaryLabel: 'Edit Meal',
        secondaryIcon: Icons.edit_outlined,
        onSecondary: onEdit,
        primaryLabel: 'Add to Log',
        primaryIcon: Icons.check_rounded,
        onPrimary: onSave,
        isLoading: isSaving,
        errorMessage: errorMessage,
      ),
    );
  }
}
