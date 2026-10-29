import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/progress/view_models/strength_level_view_model.dart';
import 'package:floww/core/progress/views/log_benchmark_sheet.dart';
import 'package:floww/core/progress/widgets/strength_muscle_card.dart';
import 'package:floww/core/progress/widgets/strength_radar_chart.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class StrengthLevelView extends StatelessWidget {
  const StrengthLevelView({super.key});

  void _openInfo(BuildContext context, StrengthLevelViewModel viewModel) {
    HapticManager.light();
    AppInfoSheet.show(
      context,
      title: viewModel.infoTitle,
      message: viewModel.infoMessage,
    );
  }

  void _logBenchmark(
    BuildContext context,
    StrengthLevelViewModel viewModel,
    MuscleGroup group,
  ) {
    HapticManager.light();
    LogBenchmarkSheet.show(
      context: context,
      viewModel: viewModel,
      group: group,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StrengthLevelViewModel>();
    final errorMessage = viewModel.errorMessage;

    return InnerPageScaffold(
      title: viewModel.title,
      onBack: () => NavigationService.instance.pop(),
      onMore: () => _openInfo(context, viewModel),
      children: [
        if (viewModel.isLoading)
          const AppSectionLoader()
        else if (errorMessage != null)
          AppErrorCard(message: errorMessage)
        else ...[
          StrengthRadarChart(axes: viewModel.radarAxes),
          SizedBox(height: AppSpacing.xl3),
          Text(
            viewModel.assessmentMessage,
            style: AppTypography.heading4Medium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          for (final muscle in viewModel.muscles) ...[
            SizedBox(height: AppSpacing.xl),
            StrengthMuscleCard(
              muscle: muscle,
              emptyValueLabel: viewModel.emptyValueLabel,
              addLabel: viewModel.addLabel,
              logAgainLabel: viewModel.logAgainLabel,
              onTap: () => _logBenchmark(context, viewModel, muscle.group),
            ),
          ],
        ],
      ],
    );
  }
}
