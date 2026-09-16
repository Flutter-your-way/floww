import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_day_grid.dart';
import 'package:floww/core/habits/widgets/habit_legend_row.dart';
import 'package:floww/core/habits/widgets/habit_period_button.dart';

class HabitProgressCalendarCard extends StatelessWidget {
  const HabitProgressCalendarCard({
    super.key,
    required this.title,
    required this.periodLabel,
    required this.weekdayLabels,
    required this.days,
    required this.legend,
    this.onSelectPeriod,
  });

  final String title;
  final String periodLabel;
  final List<String> weekdayLabels;
  final List<CalendarDayItem?> days;
  final List<HabitLegendItem> legend;
  final VoidCallback? onSelectPeriod;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.heading3Medium,
            trailing: HabitPeriodButton(
              label: periodLabel,
              onPressed: onSelectPeriod,
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          HabitDayGrid(weekdayLabels: weekdayLabels, days: days),
          SizedBox(height: AppSpacing.xl2),
          HabitLegendRow(items: legend),
        ],
      ),
    );
  }
}
