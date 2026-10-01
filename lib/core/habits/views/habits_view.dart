import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/sheets/app_date_sheet.dart';
import 'package:floww/core/habits/view_models/habits_view_model.dart';
import 'package:floww/core/habits/views/add_habit_sheet.dart';
import 'package:floww/core/habits/widgets/habit_score_card.dart';
import 'package:floww/core/habits/widgets/habits_empty_state_card.dart';
import 'package:floww/core/habits/widgets/popular_habits_card.dart';
import 'package:floww/core/habits/widgets/today_habits_card.dart';
import 'package:floww/core/habits/widgets/weekly_progress_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:floww/navigation/view_models/main_tab_controller.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  bool _pendingCreate = false;
  bool _showAddButton = true;
  MainTabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = context.read<MainTabController?>();
    _tabController?.addListener(_onTabChanged);
    _takePendingCreate();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (_takePendingCreate()) setState(() {});
  }

  bool _onScroll(UserScrollNotification notification) {
    final show = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _showAddButton,
    };
    if (show != _showAddButton) setState(() => _showAddButton = show);
    return false;
  }

  bool _takePendingCreate() {
    final controller = _tabController;
    if (controller == null || !controller.shouldCreateHabit) return false;
    controller.consumeHabitCreation();
    _pendingCreate = true;
    return true;
  }

  void _openPendingCreate(HabitsViewModel viewModel) {
    if (!_pendingCreate || viewModel.isLoading) return;
    _pendingCreate = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _addHabit(context, viewModel);
    });
  }

  Future<void> _pickDate(
    BuildContext context,
    HabitsViewModel viewModel,
  ) async {
    final picked = await AppDateSheet.show(
      context,
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
    String? createdId;
    await AddHabitSheet.show(
      context: context,
      suggestions: viewModel.suggestions,
      groups: viewModel.suggestionGroups,
      onAdd: viewModel.addSuggestion,
      onCreateCustom: (draft) async {
        createdId = await viewModel.addCustomHabit(draft);
      },
    );
    if (createdId == null) return;
    await NavigationService.instance.push(
      AppRouter.habitDetails,
      arguments: createdId,
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
          final errorMessage = viewModel.errorMessage;
          final actionMessage = viewModel.actionMessage;
          final revealTrigger = viewModel.selectedDate;
          final showCurrentEmpty =
              !viewModel.isFuture && viewModel.showEmptyState;
          final showCurrentHabits =
              !viewModel.isFuture && !viewModel.showEmptyState;
          _openPendingCreate(viewModel);

          return Stack(
            fit: StackFit.expand,
            children: [
              NotificationListener<UserScrollNotification>(
                onNotification: _onScroll,
                child: AppBackground(
                  mode: AppBackgroundMode.active(context),
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
                        if (viewModel.isLoading)
                          const AppSectionLoader()
                        else if (errorMessage != null)
                          AppErrorCard(
                            message: errorMessage,
                            onRetry: viewModel.retry,
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppPopReveal(
                                child: actionMessage != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: AppErrorCard(
                                          message: actionMessage,
                                        ),
                                      )
                                    : null,
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                child: viewModel.isReadOnly
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: TipCard.note(
                                          title: viewModel.readOnlyLabel,
                                        ),
                                      )
                                    : null,
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                child: viewModel.isFuture
                                    ? AppEmptyStateCard(
                                        title: viewModel.futureTitle,
                                        message: viewModel.futureMessage,
                                        iconAsset: AppImages.tab_4,
                                      )
                                    : null,
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                child:
                                    viewModel.isFuture &&
                                        viewModel.showPlannedHabits
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: AppSpacing.lg,
                                        ),
                                        child: TodayHabitsCard(
                                          title: viewModel.habitsTitle,
                                          items: viewModel.habits,
                                          onOpen: (item) =>
                                              NavigationService.instance.push(
                                                AppRouter.habitDetails,
                                                arguments: item.id,
                                              ),
                                        ),
                                      )
                                    : null,
                              ),
                              LuminosityLayer(
                                enabled: viewModel.isReadOnly,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: showCurrentEmpty
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppSpacing.lg,
                                              ),
                                              child: HabitsEmptyStateCard(
                                                title: viewModel.emptyTitle,
                                                message: viewModel.emptyMessage,
                                                buttonLabel: viewModel
                                                    .createFirstHabitLabel,
                                                onCreateHabit: () => _addHabit(
                                                  context,
                                                  viewModel,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: showCurrentEmpty
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppSpacing.lg,
                                              ),
                                              child: PopularHabitsCard(
                                                items: viewModel.popularHabits,
                                                onSelect: viewModel.canEdit
                                                    ? (item) => viewModel
                                                          .addSuggestedHabit(
                                                            item.id,
                                                          )
                                                    : null,
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: showCurrentHabits
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppSpacing.lg,
                                              ),
                                              child: HabitScoreCard(
                                                scoreLabel:
                                                    viewModel.scoreLabel,
                                                scoreTotalLabel:
                                                    viewModel.scoreTotalLabel,
                                                headline: viewModel.headline,
                                                message:
                                                    viewModel.headlineMessage,
                                                dailyScoreLabel:
                                                    viewModel.dailyScoreLabel,
                                                flowPointsLabel:
                                                    viewModel.flowPointsLabel,
                                                progress: viewModel.dailyScore,
                                                stats: viewModel.stats,
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: showCurrentHabits
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppSpacing.lg,
                                              ),
                                              child: TodayHabitsCard(
                                                title: viewModel.habitsTitle,
                                                items: viewModel.habits,
                                                onToggle: viewModel.canEdit
                                                    ? (item) => viewModel
                                                          .toggleHabit(item.id)
                                                    : null,
                                                onOpen: (item) =>
                                                    NavigationService.instance
                                                        .push(
                                                          AppRouter
                                                              .habitDetails,
                                                          arguments: item.id,
                                                        ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: showCurrentHabits
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppSpacing.lg,
                                              ),
                                              child: WeeklyProgressCard(
                                                days: viewModel.weekdays,
                                                legend: viewModel.legend,
                                                onTap: () => NavigationService
                                                    .instance
                                                    .push(
                                                      AppRouter.habitCalendar,
                                                      arguments: viewModel
                                                          .selectedDate,
                                                    ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppPopReveal(
                                      trigger: revealTrigger,
                                      child: viewModel.isFuture
                                          ? null
                                          : TipCard(
                                              title: viewModel.noteTitle,
                                              message: viewModel.noteMessage,
                                              icon: Icons
                                                  .local_fire_department_rounded,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (viewModel.canAddHabit)
                Positioned(
                  right: context.sizes.screenHorizontalPadding,
                  bottom: actionsBottom,
                  child: _AddHabitButton(
                    isVisible: _showAddButton,
                    onPressed: () => _addHabit(context, viewModel),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AddHabitButton extends StatelessWidget {
  const _AddHabitButton({required this.isVisible, required this.onPressed});

  final bool isVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 1),
        duration: AppMotion.expand,
        curve: isVisible ? AppMotion.expandCurve : AppMotion.collapseCurve,
        child: AnimatedOpacity(
          opacity: isVisible ? 1 : 0,
          duration: AppMotion.expand,
          child: PillButton(
            onPressed: onPressed,
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
      ),
    );
  }
}
