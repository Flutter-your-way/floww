import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/view_models/workout_view_model.dart';
import 'package:floww/core/workout/views/muscle_anatomy_sheet.dart';
import 'package:floww/core/workout/views/program_start_sheet.dart';
import 'package:floww/core/workout/widgets/active_program_card.dart';
import 'package:floww/core/workout/widgets/workout_empty_state_card.dart';
import 'package:floww/core/workout/widgets/workout_tab_bar.dart';
import 'package:floww/core/workout/widgets/exercise_library_section.dart';
import 'package:floww/core/workout/widgets/program_list_section.dart';
import 'package:floww/core/workout/widgets/suggested_workout_card.dart';
import 'package:floww/core/workout/widgets/workout_history_section.dart';
import 'package:floww/core/workout/widgets/workout_overview_section.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
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

  void _openProgram(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramItem program,
  ) {
    final detail = viewModel.programDetailFor(program.id);
    if (detail == null) return;
    HapticManager.light();
    ProgramStartSheet.show(
      context: context,
      detail: detail,
      onStart: () {
        Navigator.of(context).maybePop();
        viewModel.startProgram(program.id);
      },
    );
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
          final overviewWorkoutId = viewModel.overviewWorkoutId;

          return Stack(
            fit: StackFit.expand,
            children: [
              AppBackground(
                mode: AppBackgroundMode.flow,
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
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl3),
                    WorkoutTabBar(
                      tabs: viewModel.tabs,
                      selected: viewModel.selectedTab,
                      onSelected: viewModel.selectTab,
                    ),
                    SizedBox(height: AppSizes.s40),
                    Padding(
                      padding: horizontalPadding,
                      child: DateChangeTransition(
                        value: viewModel.selectedDate,
                        direction: viewModel.dateDirection,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (viewModel.isLoading)
                              const AppSectionLoader()
                            else if (viewModel.errorMessage != null)
                              AppErrorCard(
                                message: viewModel.errorMessage!,
                                onRetry: viewModel.retry,
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
                                        icon:
                                            Icons.local_fire_department_rounded,
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
                                        message:
                                            viewModel.trainingEffectInfoMessage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (viewModel.showHistory)
                              WorkoutHistorySection(
                                sessions: viewModel.historySessions,
                                onOpen: (session) =>
                                    _openWorkoutDetails(session.id),
                              ),
                            if (viewModel.showEmptyState)
                              WorkoutEmptyStateCard(
                                icon: viewModel.emptyState.icon,
                                title: viewModel.emptyState.title,
                                message: viewModel.emptyState.message,
                              ),
                            if (viewModel.showSuggestion &&
                                suggestion != null) ...[
                              SizedBox(height: AppSpacing.lg),
                              SuggestedWorkoutCard(
                                title: viewModel.suggestionTitle,
                                suggestion: suggestion,
                                onStartWorkout: () => _startWorkout(viewModel),
                              ),
                            ],
                            if (viewModel.showExercises)
                              const ExerciseLibrarySection(),
                            if (viewModel.showPrograms) ...[
                              if (activeProgram != null) ...[
                                ActiveProgramCard(program: activeProgram),
                                SizedBox(height: AppSpacing.xl3),
                              ],
                              ProgramListSection(
                                programs: viewModel.programs,
                                onStart: (program) =>
                                    _openProgram(context, viewModel, program),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: context.sizes.screenHorizontalPadding,
                bottom: actionsBottom,
                child: PillButton(
                  label: 'Start Workout',
                  icon: Icons.play_arrow_rounded,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                  onPressed: () => _startWorkout(viewModel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
