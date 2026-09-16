import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_status_icon.dart';

class HabitDayGrid extends StatelessWidget {
  const HabitDayGrid({
    super.key,
    required this.weekdayLabels,
    required this.days,
  });

  final List<String> weekdayLabels;
  final List<CalendarDayItem?> days;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmallRegular.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < days.length; index += DateTime.daysPerWeek)
          Padding(
            padding: EdgeInsets.only(top: index > 0 ? AppSpacing.lg : 0),
            child: Row(
              children: [
                for (var column = 0; column < DateTime.daysPerWeek; column++)
                  Expanded(
                    child: index + column < days.length
                        ? _CalendarDay(item: days[index + column])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.item});

  final CalendarDayItem? item;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (item == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HabitStatusIcon(
          status: item.status,
          progress: item.progress,
          size: AppSizes.s24,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: item.isToday
                ? context.colors.primaryAlt
                : context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
