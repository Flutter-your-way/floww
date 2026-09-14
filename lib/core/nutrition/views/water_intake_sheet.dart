import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/water_intake_view_model.dart';
import 'package:floww/core/nutrition/widgets/goal_ring_summary.dart';
import 'package:floww/core/nutrition/widgets/nutrition_tip_card.dart';
import 'package:floww/core/nutrition/widgets/water_log_card.dart';
import 'package:floww/core/nutrition/widgets/water_quick_add_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WaterIntakeSheet extends StatelessWidget {
  const WaterIntakeSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required NutritionGoal goal,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => WaterIntakeViewModel(NutritionLogService(), date, goal),
        child: const WaterIntakeSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterIntakeViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: 'Water Intake',
            subtitle: 'Daily hydration tracker',
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: GoalRingSummary(
                    goalValue: viewModel.goalLabel,
                    remainingValue: viewModel.remainingLabel,
                    shareLabel: viewModel.percentLabel,
                    progress: viewModel.progress,
                    consumedValue: viewModel.consumedLabel,
                    consumedUnit: 'Liter',
                  ),
                ),
                if (viewModel.canEdit) ...[
                  SizedBox(height: AppSpacing.lg),
                  WaterQuickAddCard(
                    amounts: WaterIntakeViewModel.quickAmounts,
                    isCustomOpen: viewModel.isCustomOpen,
                    customHint: viewModel.customHint,
                    isSaving: viewModel.isSaving,
                    onAdd: viewModel.addQuick,
                    onToggleCustom: viewModel.toggleCustom,
                    onCustomChanged: viewModel.updateCustom,
                    onAddCustom: viewModel.canAddCustom
                        ? viewModel.addCustom
                        : null,
                  ),
                ],
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
                WaterLogCard(
                  title: viewModel.logTitle,
                  entries: viewModel.logs,
                  emptyMessage: viewModel.emptyLogMessage,
                  foodWaterLabel: viewModel.foodWaterLabel,
                  onDelete: viewModel.canEdit ? viewModel.delete : null,
                ),
                SizedBox(height: AppSpacing.lg),
                NutritionTipCard(
                  title: 'Hydration Tip',
                  message: viewModel.tipMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
