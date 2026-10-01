import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/view_models/micronutrient_sources_view_model.dart';
import 'package:floww/core/nutrition/widgets/micronutrient_summary_card.dart';
import 'package:floww/core/nutrition/widgets/nutrient_source_list.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MicronutrientSourcesSheet extends StatelessWidget {
  const MicronutrientSourcesSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required NutritionDay day,
    required MicronutrientKind kind,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => MicronutrientSourcesViewModel(day, kind),
        child: const MicronutrientSourcesSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MicronutrientSourcesViewModel>(
      builder: (context, viewModel, child) {
        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: 'Breakdown by food logged',
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MicronutrientSummaryCard(
                  kind: viewModel.selected,
                  label: viewModel.labelOf(viewModel.selected),
                  amountLabel: viewModel.amountLabel,
                  goalLabel: viewModel.goalLabel,
                  progress: viewModel.progress,
                  percentLabel: viewModel.percentLabel,
                  statusLabel: viewModel.statusLabel,
                  isOverLimit: viewModel.isOverLimit,
                ),
                SizedBox(height: AppSpacing.lg),
                NutrientSourceList(
                  title: viewModel.sourcesTitle,
                  items: viewModel.sources,
                  emptyMessage: viewModel.emptyMessage,
                  isOverLimit: viewModel.isOverLimit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
