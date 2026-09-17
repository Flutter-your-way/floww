import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/widgets/flow_score_component_tile.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FlowScoreBreakdownSheet extends StatelessWidget {
  const FlowScoreBreakdownSheet({super.key, required this.breakdown});

  final FlowScoreBreakdown breakdown;

  static Future<void> show(
    BuildContext context, {
    required FlowScoreBreakdown breakdown,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => FlowScoreBreakdownSheet(breakdown: breakdown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final components = breakdown.components;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Flow Score Breakdown',
        titleStyle: context.textTheme.titleLarge,
        closeButtonSize: AppSizes.s32,
        closeIconSize: AppSizes.s16,
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _BreakdownSummary(breakdown: breakdown),
            for (final component in components) ...[
              SizedBox(height: AppSpacing.xl2),
              FlowScoreComponentTile(component: component),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownSummary extends StatelessWidget {
  const _BreakdownSummary({required this.breakdown});

  final FlowScoreBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: AppShapes.decoration(
        gradient: context.gradients.glowCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.colors.borderGlow, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              value: breakdown.todayPercent,
              label: "Today's Score",
              highlighted: true,
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryStat(
              value: breakdown.weeklyAveragePercent,
              label: '7-Day Avg',
              highlighted: false,
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryStat(
              value: breakdown.pointsLeftPercent,
              label: 'pts left',
              highlighted: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s1,
      height: AppSizes.s40,
      color: context.colors.borderSubtle,
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.highlighted,
  });

  final int value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final valueColor = highlighted
        ? context.colors.primary
        : context.colors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: context.textTheme.displayMedium?.copyWith(
                color: valueColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(
                '%',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: highlighted
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
