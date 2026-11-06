import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/charts/app_line_chart.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/stats/app_stat_column.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/health/models/health_metric_kind.dart';
import 'package:floww/core/health/view_models/health_metric_detail_view_model.dart';

class HealthMetricTrendCard extends StatelessWidget {
  const HealthMetricTrendCard({super.key, required this.viewModel});

  final HealthMetricDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: viewModel.chartTitle,
            titleStyle: context.textTheme.titleLarge,
          ),
          SizedBox(height: AppSpacing.lg),
          AppChipTabs<HealthMetricRange>(
            items: viewModel.ranges,
            selected: viewModel.range,
            labelOf: viewModel.rangeLabelOf,
            onSelected: viewModel.selectRange,
          ),
          SizedBox(height: AppSpacing.xl),
          if (viewModel.hasChart)
            AppLineChart(
              samples: viewModel.chartSamples,
              axisLabels: viewModel.axisLabels,
              dateLabels: viewModel.dateLabels,
              minValue: viewModel.axisMin,
              maxValue: viewModel.axisMax,
              showDots: viewModel.showDots,
            )
          else
            Text(
              viewModel.emptyRangeMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppStatColumn(
                  label: viewModel.averageLabel,
                  value: viewModel.averageValue,
                ),
              ),
              Expanded(
                child: AppStatColumn(
                  label: viewModel.lowestLabel,
                  value: viewModel.lowestValue,
                ),
              ),
              Expanded(
                child: AppStatColumn(
                  label: viewModel.highestLabel,
                  value: viewModel.highestValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
