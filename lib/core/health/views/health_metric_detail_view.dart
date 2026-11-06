import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/health/view_models/health_metric_detail_view_model.dart';
import 'package:floww/core/health/widgets/health_metric_about_card.dart';
import 'package:floww/core/health/widgets/health_metric_headline.dart';
import 'package:floww/core/health/widgets/health_metric_history_card.dart';
import 'package:floww/core/health/widgets/health_metric_trend_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HealthMetricDetailView extends StatelessWidget {
  const HealthMetricDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthMetricDetailViewModel>();

    return InnerPageScaffold(
      title: viewModel.title,
      onBack: () => NavigationService.instance.pop(),
      children: [
        if (!viewModel.hasReading)
          AppEmptyStateCard(
            title: viewModel.emptyTitle,
            message: viewModel.emptyMessage,
            icon: Icons.monitor_heart_outlined,
          )
        else ...[
          HealthMetricHeadline(
            value: viewModel.latestValueLabel,
            unit: viewModel.unit,
            dateLabel: viewModel.latestDateLabel,
            sourceLabel: viewModel.sourceLabel,
            trend: viewModel.trend,
            isImproving: viewModel.isImproving,
            changeLabel: viewModel.changeLabel,
          ),
          SizedBox(height: AppSpacing.xl2),
          HealthMetricTrendCard(viewModel: viewModel),
          if (viewModel.hasHistory) ...[
            SizedBox(height: AppSpacing.xl2),
            HealthMetricHistoryCard(
              title: viewModel.historyTitle,
              rows: viewModel.historyRows,
            ),
          ],
        ],
        SizedBox(height: AppSpacing.xl2),
        HealthMetricAboutCard(
          title: viewModel.aboutTitle,
          message: viewModel.about,
        ),
      ],
    );
  }
}
