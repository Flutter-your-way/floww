import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_day_grid.dart';
import 'package:floww/core/habits/widgets/habit_legend_row.dart';

class HabitCalendarCard extends StatelessWidget {
  const HabitCalendarCard({
    super.key,
    required this.monthLabel,
    required this.weekdayLabels,
    required this.days,
    required this.legend,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final String monthLabel;
  final List<String> weekdayLabels;
  final List<CalendarDayItem?> days;
  final List<HabitLegendItem> legend;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircularHeaderButton(
                icon: Icons.chevron_left_rounded,
                onPressed: onPreviousMonth,
                backgroundColor: Colors.transparent,
                iconColor: context.colors.textSecondary,
                size: AppSizes.s24,
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLargeSemiBold,
                ),
              ),
              CircularHeaderButton(
                icon: Icons.chevron_right_rounded,
                onPressed: onNextMonth,
                backgroundColor: Colors.transparent,
                iconColor: context.colors.textSecondary,
                size: AppSizes.s24,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          HabitDayGrid(weekdayLabels: weekdayLabels, days: days),
          SizedBox(height: AppSpacing.xl),
          HabitLegendRow(items: legend),
        ],
      ),
    );
  }
}
