import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/nutrition/models/weekly_metric.dart';
import 'package:floww/core/nutrition/view_models/weekly_report_view_model.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/core/nutrition/widgets/weekly_report_cards.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WeeklyReportView extends StatelessWidget {
  const WeeklyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyReportViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: 'Weekly Nutrition Report',
          onBack: () => NavigationService.instance.pop(),
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: context.colors.textSecondary,
                  size: AppSizes.s16,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  viewModel.rangeLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            FlowContributionCard(
              pointsLabel: viewModel.totalPointsLabel,
              maxLabel: '${viewModel.maxPoints}',
              progress: viewModel.contributionProgress,
              progressLabel: viewModel.contributionLabel,
              dailyBars: viewModel.dailyPointBars,
            ),
            SizedBox(height: AppSpacing.xl),
            ConsistencyCard(
              daysLogged: viewModel.daysLoggedLabel,
              calorieStreak: viewModel.calorieStreakLabel,
              proteinStreak: viewModel.proteinStreakLabel,
              statuses: viewModel.dayStatuses,
            ),
            SizedBox(height: AppSpacing.xl),
            AppChipTabs<WeeklyMetric>(
              items: WeeklyMetric.values,
              selected: viewModel.metric,
              labelOf: (metric) => metric.label,
              onSelected: viewModel.selectMetric,
            ),
            SizedBox(height: AppSpacing.xl),
            WeeklyMetricCard(
              title: viewModel.metric.label,
              averageLabel: viewModel.metricAverageLabel,
              goalLabel: viewModel.metricGoalLabel,
              bars: viewModel.metricBars,
              color: viewModel.metric.colorOf(context),
              totalLabel: viewModel.metricTotalLabel,
              weeklyGoalLabel: viewModel.metricWeeklyGoalLabel,
              progress: viewModel.metricProgress,
            ),
            SizedBox(height: AppSpacing.xl),
            FlowPointsBreakdownCard(
              totalLabel: '${viewModel.totalPoints}',
              maxLabel: '${viewModel.maxPoints}',
              rows: viewModel.pointsBreakdown,
              tip: viewModel.tipMessage,
            ),
          ],
        );
      },
    );
  }
}
