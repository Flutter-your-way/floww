import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_legend_row.dart';
import 'package:floww/core/habits/widgets/habit_status_icon.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({
    super.key,
    required this.days,
    required this.legend,
    this.onTap,
  });

  final List<WeekdayProgressItem> days;
  final List<HabitLegendItem> legend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Weekly Progress',
            titleStyle: AppTypography.heading4SemiBold,
            showChevron: true,
            onTap: onTap,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (final day in days) Expanded(child: _WeekdayColumn(day: day)),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          HabitLegendRow(items: legend),
        ],
      ),
    );
  }
}

class _WeekdayColumn extends StatelessWidget {
  const _WeekdayColumn({required this.day});

  final WeekdayProgressItem day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.label,
          textAlign: TextAlign.center,
          style: AppTypography.labelSmallRegular.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        HabitStatusIcon(status: day.status, progress: day.progress),
        SizedBox(height: AppSpacing.sm),
        Text(
          day.percentLabel,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
