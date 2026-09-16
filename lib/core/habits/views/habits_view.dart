import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/core/habits/view_models/habits_view_model.dart';
import 'package:floww/core/habits/views/add_habit_sheet.dart';
import 'package:floww/core/habits/widgets/habit_score_card.dart';
import 'package:floww/core/habits/widgets/habits_empty_state_card.dart';
import 'package:floww/core/habits/widgets/popular_habits_card.dart';
import 'package:floww/core/habits/widgets/today_habits_card.dart';
import 'package:floww/core/habits/widgets/weekly_progress_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HabitsView extends StatelessWidget {
  const HabitsView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    HabitsViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: viewModel.firstSelectableDate,
      lastDate: viewModel.lastSelectableDate,
    );
    if (picked != null) viewModel.selectDate(picked);
  }

  Future<void> _addHabit(
    BuildContext context,
    HabitsViewModel viewModel,
  ) async {
    await AddHabitSheet.show(
      context: context,
      suggestions: viewModel.suggestions,
      groups: viewModel.suggestionGroups,
      onAdd: viewModel.addSuggestion,
      onCreateCustom: viewModel.addCustomHabit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final actionsBottom = bottomInset + AppSizes.s64 + AppSpacing.xl2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<HabitsViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AppBackground(
                mode: AppBackgroundMode.flow,
                safeAreaTop: false,
                scrollable: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sizes.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.paddingOf(context).top + AppSpacing.lg,
                      ),
                      ScreenDateHeader(
                        titlePrefix: viewModel.titlePrefix,
                        title: 'Habits',
                        dateLabel: viewModel.dateLabel,
                        direction: viewModel.dateDirection,
                        onPreviousDay: viewModel.canGoPrevious
                            ? viewModel.previousDay
                            : null,
                        onNextDay: viewModel.canGoNext
                            ? viewModel.nextDay
                            : null,
                        onPickDate: () => _pickDate(context, viewModel),
                      ),
                      SizedBox(height: AppSpacing.xl4),
                      DateChangeTransition(
                        value: viewModel.selectedDate,
                        direction: viewModel.dateDirection,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (viewModel.isReadOnly) ...[
                              TipCard.note(title: viewModel.readOnlyLabel),
                              SizedBox(height: AppSpacing.lg),
                            ],
                            LuminosityLayer(
                              enabled: viewModel.isReadOnly,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (viewModel.showEmptyState) ...[
                                    HabitsEmptyStateCard(
                                      title: viewModel.emptyTitle,
                                      message: viewModel.emptyMessage,
                                      buttonLabel:
                                          viewModel.createFirstHabitLabel,
                                      onCreateHabit: () =>
                                          _addHabit(context, viewModel),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    PopularHabitsCard(
                                      items: viewModel.popularHabits,
                                      onSelect: viewModel.canEdit
                                          ? (item) => viewModel
                                                .addSuggestedHabit(item.id)
                                          : null,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                  ] else ...[
                                    HabitScoreCard(
                                      scoreLabel: viewModel.scoreLabel,
                                      scoreTotalLabel:
                                          viewModel.scoreTotalLabel,
                                      headline: viewModel.headline,
                                      message: viewModel.headlineMessage,
                                      dailyScoreLabel:
                                          viewModel.dailyScoreLabel,
                                      flowPointsLabel:
                                          viewModel.flowPointsLabel,
                                      progress: viewModel.dailyScore,
                                      stats: viewModel.stats,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    TodayHabitsCard(
                                      title: viewModel.habitsTitle,
                                      items: viewModel.habits,
                                      onToggle: viewModel.canEdit
                                          ? (item) =>
                                                viewModel.toggleHabit(item.id)
                                          : null,
                                      onOpen: (item) =>
                                          NavigationService.instance.push(
                                            AppRouter.habitDetails,
                                            arguments: item.id,
                                          ),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    WeeklyProgressCard(
                                      days: viewModel.weekdays,
                                      legend: viewModel.legend,
                                      onTap: () =>
                                          NavigationService.instance.push(
                                            AppRouter.habitCalendar,
                                            arguments: viewModel.selectedDate,
                                          ),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                  ],
                                  TipCard(
                                    title: viewModel.noteTitle,
                                    message: viewModel.noteMessage,
                                    icon: Icons.local_fire_department_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.canEdit)
                Positioned(
                  right: context.sizes.screenHorizontalPadding,
                  bottom: actionsBottom,
                  child: PillButton(
                    onPressed: () => _addHabit(context, viewModel),
                    height: AppSizes.s46,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl2,
                      vertical: AppSpacing.lg,
                    ),
                    icon: Icons.add_rounded,
                    label: 'Add a Habit',
                    labelStyle: AppTypography.labelMediumSemiBold,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
