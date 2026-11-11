import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_heatmap_grid.dart';

class HabitHeatmapCard extends StatelessWidget {
  const HabitHeatmapCard({
    super.key,
    required this.title,
    required this.data,
    this.selectedDate,
  });

  final String title;
  final HabitHeatmapData data;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: AppTypography.heading4SemiBold),
          SizedBox(height: AppSpacing.xs),
          Text(
            data.summaryLabel,
            style: AppTypography.bodySmallMediumTight.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          HabitHeatmapGrid(data: data, selectedDate: selectedDate),
          SizedBox(height: AppSpacing.lg),
          const _HeatmapLegend(),
        ],
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.captionMediumMicro.copyWith(
      color: context.colors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: style),
        for (final level in HabitHeatmapLevel.values) ...[
          SizedBox(width: AppSpacing.xs),
          HabitHeatmapCellBox(level: level),
        ],
        SizedBox(width: AppSpacing.xs),
        Text('More', style: style),
      ],
    );
  }
}
