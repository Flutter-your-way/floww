import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/widgets/flow_score_bar_chart.dart';
import 'package:floww/core/progress/widgets/progress_card_empty_state.dart';
import 'package:floww/core/progress/widgets/progress_metric_tile.dart';

class FlowScoreSummaryCard extends StatelessWidget {
  const FlowScoreSummaryCard({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.summary,
    required this.scoreLabel,
    required this.deltaLabel,
    required this.isImproving,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyButtonLabel,
    this.onStartWorkout,
  });

  final String title;
  final String rangeLabel;
  final FlowScoreSummary summary;
  final String scoreLabel;
  final String deltaLabel;
  final bool isImproving;
  final String emptyTitle;
  final String emptyMessage;
  final String emptyButtonLabel;
  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.labelLargeSemiBold,
            trailing: Text(
              rangeLabel,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          if (!summary.hasScores)
            ProgressCardEmptyState(
              icon: Icons.bolt,
              title: emptyTitle,
              message: emptyMessage,
              buttonLabel: emptyButtonLabel,
              onPressed: onStartWorkout,
            )
          else ...[
            _FlowScoreHeadline(
              scoreLabel: scoreLabel,
              deltaLabel: deltaLabel,
              isImproving: isImproving,
            ),
            SizedBox(height: AppSpacing.xl),
            _FlowScoreTiles(summary: summary),
            SizedBox(height: AppSpacing.xl),
            FlowScoreBarChart(days: summary.days),
          ],
        ],
      ),
    );
  }
}

class _FlowScoreHeadline extends StatelessWidget {
  const _FlowScoreHeadline({
    required this.scoreLabel,
    required this.deltaLabel,
    required this.isImproving,
  });

  final String scoreLabel;
  final String deltaLabel;
  final bool isImproving;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final deltaColor = isImproving ? colors.primary : colors.accentOrange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          scoreLabel,
          style: AppTypography.bodyXXXLargeBold.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isImproving
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: AppSizes.s14,
                color: deltaColor,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                deltaLabel,
                style: AppTypography.bodySmallBoldTight.copyWith(
                  color: deltaColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowScoreTiles extends StatelessWidget {
  const _FlowScoreTiles({required this.summary});

  final FlowScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ProgressMetricTile(
              label: 'Best Day',
              value: '${summary.bestScore}',
              caption: summary.bestDay,
              valueColor: colors.primaryAlt,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: ProgressMetricTile(
              label: 'Worst Day',
              value: '${summary.worstScore}',
              caption: summary.worstDay,
              valueColor: colors.accentOrange,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: ProgressMetricTile(
              label: 'Average',
              value: '${summary.averageScore}',
              caption: 'This week',
              valueColor: colors.textQuiet,
            ),
          ),
        ],
      ),
    );
  }
}
