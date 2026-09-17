import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/habits/view_models/habit_calendar_view_model.dart';
import 'package:floww/core/habits/widgets/habit_calendar_card.dart';
import 'package:floww/core/habits/widgets/habit_streaks_card.dart';
import 'package:floww/core/habits/widgets/habit_summary_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HabitCalendarView extends StatelessWidget {
  const HabitCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitCalendarViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: 'Habit Calendar',
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else if (errorMessage != null)
              AppErrorCard(message: errorMessage, onRetry: viewModel.retry)
            else ...[
              HabitSummaryCard(
                bestStreakValue: viewModel.bestStreakValue,
                bestStreakUnit: viewModel.bestStreakUnit,
                topHabitTitle: viewModel.topHabitTitle,
              ),
              SizedBox(height: AppSpacing.lg),
              HabitCalendarCard(
                monthLabel: viewModel.monthLabel,
                weekdayLabels: viewModel.weekdayLabels,
                days: viewModel.days,
                legend: viewModel.legend,
                onPreviousMonth: viewModel.canGoPrevious
                    ? viewModel.previousMonth
                    : null,
                onNextMonth: viewModel.canGoNext ? viewModel.nextMonth : null,
              ),
              SizedBox(height: AppSpacing.lg),
              HabitStreaksCard(items: viewModel.streaks),
            ],
          ],
        );
      },
    );
  }
}
