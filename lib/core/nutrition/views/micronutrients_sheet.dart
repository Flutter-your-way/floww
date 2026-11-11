import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/nutrition/view_models/nutrition_view_model.dart';
import 'package:floww/core/nutrition/views/micronutrient_sources_sheet.dart';
import 'package:floww/core/nutrition/widgets/micronutrient_breakdown.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MicronutrientsSheet extends StatelessWidget {
  const MicronutrientsSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required NutritionViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider<NutritionViewModel>.value(
        value: viewModel,
        child: const MicronutrientsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionViewModel>(
      builder: (context, viewModel, child) {
        return AppFloatingSheet(
          child: AppSheetPanel(
            title: 'Micronutrients',
            subtitle: viewModel.micronutrientsSummaryLabel,
            onClose: () => NavigationService.instance.pop(),
            body: MicronutrientBreakdown(
              limits: viewModel.limitNutrients,
              items: viewModel.micronutrients,
              note: viewModel.micronutrientsNote,
              onOpenNutrient: (kind) => MicronutrientSourcesSheet.show(
                context,
                day: viewModel.day,
                kind: kind,
              ),
            ),
          ),
        );
      },
    );
  }
}
