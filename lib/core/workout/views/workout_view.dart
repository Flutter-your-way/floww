import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/widgets/animations/tab_content_switcher.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/config/widgets/sheets/app_date_sheet.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/view_models/workout_view_model.dart';
import 'package:floww/core/workout/views/missed_workout_sheet.dart';
import 'package:floww/core/workout/views/muscle_anatomy_sheet.dart';
import 'package:floww/core/workout/views/program_detail_sheet.dart';
import 'package:floww/core/workout/views/program_start_sheet.dart';
import 'package:floww/core/workout/widgets/active_program_card.dart';
import 'package:floww/core/workout/widgets/active_workout_fab.dart';
import 'package:floww/core/workout/widgets/workout_empty_state_card.dart';
import 'package:floww/core/workout/widgets/workout_tab_bar.dart';
import 'package:floww/core/workout/widgets/exercise_library_section.dart';
import 'package:floww/core/workout/widgets/program_list_section.dart';
import 'package:floww/core/workout/widgets/suggested_workout_card.dart';
import 'package:floww/core/workout/widgets/workout_history_section.dart';
import 'package:floww/core/workout/widgets/workout_overview_section.dart';
import 'package:floww/core/workout/widgets/workout_shift_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    final picked = await AppDateSheet.show(
      context,
      initialDate: viewModel.selectedDate,
      firstDate: viewModel.firstSelectableDate,
      lastDate: viewModel.lastSelectableDate,
    );
    if (picked != null) viewModel.selectDate(picked);
  }

  void _startWorkout(WorkoutViewModel viewModel) {
    HapticManager.light();
    NavigationService.instance.push(
      AppRouter.todaysWorkout,
      arguments: viewModel.selectedDate,
    );
  }

  void _resumeWorkout(WorkoutViewModel viewModel) {
    HapticManager.medium();
    NavigationService.instance.push(
      AppRouter.activeWorkout,
      arguments: viewModel.selectedDate,
    );
  }

  void _toggleTimer(WorkoutViewModel viewModel) {
    HapticManager.light();
    viewModel.toggleTimer();
  }

  void _showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    HapticManager.light();
    AppInfoSheet.show(context, title: title, message: message);
  }

  void _openAnatomy(BuildContext context, WorkoutViewModel viewModel) {
    final anatomy = viewModel.anatomy;
    if (anatomy == null) return;
    HapticManager.light();
    MuscleAnatomySheet.show(context: context, anatomy: anatomy);
  }

  void _openWorkoutDetails(String workoutId) {
    HapticManager.light();
    NavigationService.instance.push(
      AppRouter.workoutDetails,
      arguments: workoutId,
    );
  }

  void _catchUp(WorkoutViewModel viewModel, MissedWorkoutItem missed) {
    HapticManager.medium();
    viewModel.catchUp(missed);
  }

  void _openMissed(
    BuildContext context,
    WorkoutViewModel viewModel,
    MissedWorkoutItem missed,
  ) {
    HapticManager.light();
    MissedWorkoutSheet.show(
      context: context,
      missed: missed,
      onAction: missed.actionLabel == null
          ? null
          : () {
              Navigator.of(context).maybePop();
              _catchUp(viewModel, missed);
            },
    );
  }

  void _openProgram(
    BuildContext context,
    WorkoutViewModel viewModel,
    String id,
  ) {
    final detail = viewModel.programDetailFor(id);
    if (detail == null) return;
    HapticManager.light();
    ProgramDetailSheet.show(
      context: context,
      detail: detail,
      onStart: () {
        Navigator.of(context).maybePop();
        _setUpProgram(context, viewModel, id);
      },
      onCustomize: () {
        Navigator.of(context).maybePop();
        _openEditor(
          viewModel,
          ProgramEditorArgs(programId: id, editExisting: detail.isCustom),
        );
      },
      onDelete: detail.isCustom
          ? () => _confirmDelete(context, viewModel, detail)
          : null,
      onStop: detail.isActive
          ? () => _confirmStop(context, viewModel, detail)
          : null,
    );
  }

  void _setUpProgram(
    BuildContext context,
    WorkoutViewModel viewModel,
    String id,
  ) {
    final setup = viewModel.programStartSetupFor(id);
    if (setup == null) return;
    ProgramStartSheet.show(
      context: context,
      setup: setup,
      onStart: (config) => viewModel.startProgram(id, config),
    );
  }

  Future<void> _openEditor(
    WorkoutViewModel viewModel,
    ProgramEditorArgs args,
  ) async {
    HapticManager.light();
    final result = await NavigationService.instance.push(
      AppRouter.programEditor,
      arguments: args,
    );
    if (result is String) viewModel.showMyPrograms();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramDetailItem detail,
  ) async {
    Navigator.of(context).maybePop();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.deleteProgramTitle(detail),
      message: viewModel.deleteProgramMessage(detail),
      confirmLabel: 'Delete',
      alternateLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    viewModel.deleteProgram(detail.id);
  }

  Future<void> _confirmStop(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramDetailItem detail,
  ) async {
    Navigator.of(context).maybePop();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.stopProgramTitle(detail),
      message: viewModel.stopProgramMessage,
      confirmLabel: 'Stop program',
      alternateLabel: 'Keep going',
      icon: Icons.stop_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    viewModel.stopProgram();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final actionsBottom = bottomInset + AppSizes.s64 + AppSpacing.xl2;
    final horizontalPadding = EdgeInsets.symmetric(
      horizontal: context.sizes.screenHorizontalPadding,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<WorkoutViewModel>(
        builder: (context, viewModel, child) {
          final suggestion = viewModel.suggestion;
          final overview = viewModel.overview;
          final activeProgram = viewModel.activeProgram;
          final activeProgramId = viewModel.activeProgramId;
          final overviewWorkoutId = viewModel.overviewWorkoutId;
          final shiftOffer = viewModel.shiftOffer;
          final history = viewModel.showHistory ? viewModel.history : null;

          return Stack(
            fit: StackFit.expand,
            children: [
              AppBackground(
                mode: AppBackgroundMode.active(context),
                safeAreaTop: false,
                scrollable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.paddingOf(context).top + AppSpacing.lg,
                    ),
                    Padding(
                      padding: horizontalPadding,
                      child: ScreenDateHeader(
                        titlePrefix: viewModel.titlePrefix,
                        title: 'Workouts',
                        dateLabel: viewModel.dateLabel,
                        direction: viewModel.dateDirection,
                        onPreviousDay: viewModel.canGoPrevious
                            ? viewModel.previousDay
                            : null,
                        onNextDay: viewModel.canGoNext
                            ? viewModel.nextDay
                            : null,
                        onPickDate: () => _pickDate(context, viewModel),
                        showDateSelector: viewModel.showDateSelector,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl3),
                    WorkoutTabBar(
                      tabs: viewModel.tabs,
                      selected: viewModel.selectedTab,
                      onSelected: viewModel.selectTab,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: horizontalPadding,
                      child: DateChangeTransition(
                        value: viewModel.selectedDate,
                        direction: viewModel.dateDirection,
                        child: TabContentSwitcher(
                          reverse: viewModel.tabReverse,
                          child: Column(
                            key: ValueKey(viewModel.selectedTab),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (viewModel.isLoading ||
                                  viewModel.isHistoryLoading)
                                const AppSectionLoader()
                              else if (viewModel.errorMessage != null)
                                AppErrorCard(
                                  message: viewModel.errorMessage!,
                                  onRetry: viewModel.retry,
                                ),
                              AppPopReveal(
                                child: shiftOffer == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: WorkoutShiftCard(
                                          title: shiftOffer.title,
                                          message: shiftOffer.message,
                                          actionLabel: shiftOffer.actionLabel,
                                          isLoading: viewModel.isShifting,
                                          onAction: () {
                                            HapticManager.medium();
                                            viewModel.applyShift();
                                          },
                                        ),
                                      ),
                              ),
                              if (viewModel.showOverview && overview != null)
                                LuminosityLayer(
                                  enabled: viewModel.isReadOnly,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (viewModel.showReadOnlyBanner) ...[
                                        TipCard(
                                          title: viewModel.readOnlyLabel,
                                          icon: Icons
                                              .local_fire_department_rounded,
                                        ),
                                        SizedBox(height: AppSpacing.lg),
                                      ],
                                      WorkoutOverviewSection(
                                        overview: overview,
                                        showSummary: !viewModel.isReadOnly,
                                        onViewAnatomy: () =>
                                            _openAnatomy(context, viewModel),
                                        onViewDetails: overviewWorkoutId == null
                                            ? null
                                            : () => _openWorkoutDetails(
                                                overviewWorkoutId,
                                              ),
                                        onSummaryInfo: () => _showInfo(
                                          context,
                                          title: 'Workout Summary',
                                          message: viewModel.summaryInfoMessage,
                                        ),
                                        onTrainingEffectInfo: () => _showInfo(
                                          context,
                                          title: 'Training Effect',
                                          message: viewModel
                                              .trainingEffectInfoMessage,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (viewModel.showHistory && history != null)
                                WorkoutHistorySection(
                                  history: history,
                                  isCatchingUp: viewModel.isShifting,
                                  onOpen: (session) =>
                                      _openWorkoutDetails(session.id),
                                  onOpenMissed: (missed) =>
                                      _openMissed(context, viewModel, missed),
                                  onCatchUp: (missed) =>
                                      _catchUp(viewModel, missed),
                                ),
                              if (viewModel.showEmptyState)
                                WorkoutEmptyStateCard(
                                  icon: viewModel.emptyState.icon,
                                  title: viewModel.emptyState.title,
                                  message: viewModel.emptyState.message,
                                ),
                              AppPopReveal(
                                child:
                                    viewModel.showSuggestion &&
                                        suggestion != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: AppSpacing.lg,
                                        ),
                                        child: SuggestedWorkoutCard(
                                          title: viewModel.suggestionTitle,
                                          suggestion: suggestion,
                                          onStartWorkout: () =>
                                              _startWorkout(viewModel),
                                        ),
                                      )
                                    : null,
                              ),
                              if (viewModel.showExercises)
                                const ExerciseLibrarySection(),
                              if (viewModel.showPrograms) ...[
                                if (activeProgram != null &&
                                    activeProgramId != null) ...[
                                  ActiveProgramCard(
                                    program: activeProgram,
                                    onTap: () => _openProgram(
                                      context,
                                      viewModel,
                                      activeProgramId,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xl3),
                                ],
                                ProgramListSection(
                                  programs: viewModel.programs,
                                  goalFilters: viewModel.goalFilters,
                                  levelFilters: viewModel.levelFilters,
                                  countLabel: viewModel.programsCountLabel,
                                  emptyMessage: viewModel.programsEmptyMessage,
                                  onSelectGoal: viewModel.selectGoalFilter,
                                  onSelectLevel: viewModel.selectLevelFilter,
                                  onOpen: (program) => _openProgram(
                                    context,
                                    viewModel,
                                    program.id,
                                  ),
                                  onCreate: () => _openEditor(
                                    viewModel,
                                    const ProgramEditorArgs(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                    ),
                  ],
                ),
              ),
              if (viewModel.primaryAction == WorkoutPrimaryAction.start)
                Positioned(
                  right: context.sizes.screenHorizontalPadding,
                  bottom: actionsBottom,
                  child: PillButton(
                    label: viewModel.primaryActionLabel,
                    icon: Icons.play_arrow_rounded,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                    onPressed: () => _startWorkout(viewModel),
                  ),
                ),
              if (viewModel.primaryAction == WorkoutPrimaryAction.resume)
                Positioned(
                  right: context.sizes.screenHorizontalPadding,
                  bottom: actionsBottom,
                  child: ActiveWorkoutFab(
                    statusLabel: viewModel.activeStatusLabel,
                    timerLabel: viewModel.activeTimerLabel,
                    isPaused: viewModel.isTimerPaused,
                    onOpen: () => _resumeWorkout(viewModel),
                    onTogglePause: () => _toggleTimer(viewModel),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
