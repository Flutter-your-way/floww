import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/effects/edge_fade_mask.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/views/active_exercise_options_sheet.dart';
import 'package:floww/core/workout/views/edit_set_sheet.dart';
import 'package:floww/core/workout/views/swap_exercise_sheet.dart';
import 'package:floww/core/workout/views/workout_completion_flow.dart';
import 'package:floww/core/workout/views/workout_queue_sheet.dart';
import 'package:floww/core/workout/widgets/active_exercise_hero_card.dart';
import 'package:floww/core/workout/widgets/active_metric_pill.dart';
import 'package:floww/core/workout/widgets/active_workout_action_bar.dart';
import 'package:floww/core/workout/widgets/active_workout_progress_header.dart';
import 'package:floww/core/workout/widgets/exercise_info_section_card.dart';
import 'package:floww/core/workout/widgets/rest_end_listener.dart';
import 'package:floww/core/workout/widgets/rest_timer_card.dart';
import 'package:floww/core/workout/widgets/set_input_card.dart';
import 'package:floww/core/workout/widgets/set_progress_dots.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ActiveWorkoutView extends StatelessWidget {
  const ActiveWorkoutView({super.key});

  static const double _headerBlockHeight = AppSizes.s40;
  static const double _actionBarHeight = AppSizes.s56;

  void _exit() {
    HapticManager.light();
    NavigationService.instance.pop();
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) async {
    HapticManager.light();
    final choice = await AppConfirmSheet.show(
      context,
      title: 'Cancel Workout?',
      message:
          'This discards the session and any sets you logged. Your plan for '
          'today stays, so you can start it again later.',
      confirmLabel: 'Cancel Workout',
      alternateLabel: 'Keep Going',
      icon: Icons.close_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    if (await viewModel.cancel()) NavigationService.instance.pop();
  }

  Future<void> _openOptions(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) async {
    HapticManager.light();
    final action = await ActiveExerciseOptionsSheet.show(context, viewModel);
    if (action == null || !context.mounted) return;
    switch (action) {
      case ActiveOptionAction.undoLastSet:
        viewModel.undoLastSet();
      case ActiveOptionAction.addSet:
        viewModel.addSet();
      case ActiveOptionAction.removeSet:
        viewModel.removeSet();
      case ActiveOptionAction.swapExercise:
        await SwapExerciseSheet.show(context, viewModel);
      case ActiveOptionAction.superset:
        viewModel.toggleSuperset();
      case ActiveOptionAction.reorder:
        await WorkoutQueueSheet.show(context, viewModel);
      case ActiveOptionAction.finishEarly:
        await _confirmFinish(context, viewModel);
    }
  }

  Future<void> _confirmFinish(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) async {
    final choice = await AppConfirmSheet.show(
      context,
      title: 'Finish Workout?',
      message:
          'WAVE will save the sets you logged and mark the rest of this '
          'session as not done.',
      confirmLabel: 'Finish Now',
      alternateLabel: 'Keep Going',
      icon: Icons.flag_outlined,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.success();
    await viewModel.finishEarly();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final actionsBottom = viewPadding.bottom + AppSpacing.xl;
    final contentTop =
        viewPadding.top + kToolbarHeight + _headerBlockHeight + AppSpacing.xl;

    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.shouldStartCompletion) {
          viewModel.markCompletionStarted();
          final completionViewModel = viewModel.completionViewModel();
          if (completionViewModel != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => WorkoutCompletionFlow.start(
                context: context,
                viewModel: completionViewModel,
              ),
            );
          }
        }
        final session = viewModel.session;
        if (session == null) {
          return _ActiveWorkoutPlaceholder(
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            onRetry: viewModel.load,
            onExit: _exit,
          );
        }

        return RestEndListener(
          events: viewModel.restEnded,
          child: Scaffold(
            backgroundColor: context.colors.backgroundPrimary,
            body: AppBackground(
              mode: AppBackgroundMode.active(context),
              isInner: true,
              safeAreaTop: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: EdgeFadeMask(
                      topFadeEnd: contentTop,
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: contentTop,
                          bottom:
                              actionsBottom + _actionBarHeight + AppSpacing.xl3,
                          left: horizontalPadding,
                          right: horizontalPadding,
                        ),
                        children: [
                          if (session.isResting)
                            RestTimerCard(
                              secondsLabel: session.restSecondsLabel,
                              nextUpLabel: session.nextUpLabel,
                              canShorten: session.canShortenRest,
                              onSkip: viewModel.skipRest,
                              onAdjust: (steps) {
                                HapticManager.selection();
                                viewModel.adjustRest(steps);
                              },
                            )
                          else
                            _ExerciseContent(
                              exercise: session.exercise,
                              viewModel: viewModel,
                              onOptions: () => _openOptions(context, viewModel),
                              onEditSet: (index) {
                                HapticManager.light();
                                EditSetSheet.show(context, viewModel, index);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: viewPadding.top,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomHeader(
                          isTimerMode: true,
                          timeText: session.timerLabel,
                          onBackPressed: _exit,
                          onClosePressed: () =>
                              _confirmCancel(context, viewModel),
                        ),
                        ActiveWorkoutProgressHeader(
                          progress: session.progress,
                          exerciseLabel: session.exerciseLabel,
                          setLabel: session.setLabel,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomActionScrim(
                      height:
                          viewPadding.bottom +
                          AppSizes.s72 +
                          context.sizes.bottomScrimExtra,
                    ),
                  ),
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: actionsBottom,
                    child: ActiveWorkoutActionBar(
                      label: session.primaryActionLabel,
                      isResting: session.isResting,
                      isPaused: session.isPaused,
                      onPrimary: () {
                        HapticManager.medium();
                        viewModel.completeSet();
                      },
                      onTogglePause: () {
                        HapticManager.light();
                        viewModel.togglePause();
                      },
                      onSkip: () {
                        HapticManager.light();
                        viewModel.skipExercise();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({
    required this.exercise,
    required this.viewModel,
    required this.onOptions,
    required this.onEditSet,
  });

  final ActiveExerciseItem exercise;
  final ActiveWorkoutViewModel viewModel;
  final VoidCallback onOptions;
  final ValueChanged<int> onEditSet;

  @override
  Widget build(BuildContext context) {
    final input = exercise.input;
    final lastTimeLabel = exercise.lastTimeLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActiveExerciseHeroCard(exercise: exercise, onOptions: onOptions),
        SizedBox(height: AppSpacing.xl2),
        SetProgressDots(dots: exercise.setDots, onTapLogged: onEditSet),
        if (lastTimeLabel != null) ...[
          SizedBox(height: AppSpacing.lg),
          Align(
            child: ActiveMetricPill(
              icon: Icons.history_rounded,
              value: 'Last',
              label: lastTimeLabel,
            ),
          ),
        ],
        SizedBox(height: AppSpacing.xl2),
        SetInputCard(
          primary: input.primary,
          weight: input.weight,
          reserve: input.reserve,
          typeOptions: input.typeOptions,
          onAdjustPrimary: viewModel.adjustPrimary,
          onAdjustWeight: viewModel.adjustWeight,
          onAdjustReserve: viewModel.adjustReserve,
          onSelectType: viewModel.selectSetType,
        ),
        SizedBox(height: AppSpacing.xl3),
        for (var i = 0; i < exercise.infoSections.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          ExerciseInfoSectionCard(
            section: exercise.infoSections[i],
            onToggle: () =>
                viewModel.toggleSection(exercise.infoSections[i].id),
          ),
        ],
      ],
    );
  }
}

class _ActiveWorkoutPlaceholder extends StatelessWidget {
  const _ActiveWorkoutPlaceholder({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onExit,
  });

  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;
    final message = errorMessage;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AppBackground(
        mode: AppBackgroundMode.active(context),
        isInner: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomHeader(onBackPressed: onExit, onClosePressed: onExit),
              if (isLoading)
                const AppSectionLoader()
              else if (message != null)
                AppErrorCard(message: message, onRetry: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
