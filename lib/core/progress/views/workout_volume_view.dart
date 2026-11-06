import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/progress/view_models/workout_volume_view_model.dart';
import 'package:floww/core/progress/widgets/progress_bar_chart.dart';
import 'package:floww/core/progress/widgets/progress_metric_tile.dart';
import 'package:floww/core/progress/widgets/volume_session_row.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutVolumeView extends StatelessWidget {
  const WorkoutVolumeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkoutVolumeViewModel>();
    final errorMessage = viewModel.errorMessage;
    final colors = context.colors;

    return InnerPageScaffold(
      title: viewModel.title,
      onBack: () => NavigationService.instance.pop(),
      children: [
        if (viewModel.isLoading)
          const AppSectionLoader()
        else if (errorMessage != null)
          AppErrorCard(message: errorMessage)
        else if (!viewModel.hasSessions)
          AppEmptyStateCard(
            title: viewModel.emptyTitle,
            message: viewModel.emptyMessage,
            icon: Icons.fitness_center_rounded,
          )
        else ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ProgressMetricTile(
                    label: viewModel.sessionsLabel,
                    value: viewModel.sessionCountValue,
                    caption: viewModel.statsCaption,
                    valueColor: colors.primaryAlt,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProgressMetricTile(
                    label: viewModel.setsLabel,
                    value: viewModel.totalSetsValue,
                    caption: viewModel.statsCaption,
                    valueColor: colors.textPrimary,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ProgressMetricTile(
                    label: viewModel.liftedLabel,
                    value: viewModel.liftedValue,
                    caption: viewModel.statsCaption,
                    valueColor: colors.textQuiet,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardHeader(
                  title: viewModel.chartTitle,
                  titleStyle: AppTypography.heading4SemiBold,
                  trailing: Text(
                    viewModel.chartRangeLabel,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                ProgressBarChart(bars: viewModel.bars),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl3),
          Text(
            viewModel.historyTitle,
            style: AppTypography.heading4SemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          for (final item in viewModel.history) ...[
            SizedBox(height: AppSpacing.md),
            VolumeSessionRow(item: item),
          ],
        ],
      ],
    );
  }
}
