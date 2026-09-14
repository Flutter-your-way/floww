import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/view_models/macronutrients_view_model.dart';
import 'package:floww/core/nutrition/widgets/macro_detail_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MacronutrientsSheet extends StatelessWidget {
  const MacronutrientsSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required NutritionDay day,
    MacroNutrient initial = MacroNutrient.protein,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => MacronutrientsViewModel(day, initial),
        child: const MacronutrientsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MacronutrientsViewModel>(
      builder: (context, viewModel, child) {
        return AppFloatingSheet(
          child: AppSheetPanel(
            title: 'Macronutrients',
            subtitle: 'Understanding your 3 core macros',
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MacroSplitCard(
                  title: viewModel.splitTitle,
                  shares: viewModel.shares,
                ),
                SizedBox(height: AppSpacing.lg),
                AppChipTabs<MacroNutrient>(
                  items: viewModel.macros,
                  selected: viewModel.selected,
                  labelOf: (macro) => macro.tabLabel,
                  onSelected: viewModel.select,
                ),
                SizedBox(height: AppSpacing.lg),
                MacroDetailCard(
                  macro: viewModel.selected,
                  amountLabel: viewModel.amountLabel,
                  goalLabel: viewModel.goalLabel,
                  progress: viewModel.progress,
                  percentOfGoalLabel: viewModel.percentOfGoalLabel,
                  energyLabel: viewModel.energyLabel,
                  recommendedLabel: viewModel.recommendedLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
