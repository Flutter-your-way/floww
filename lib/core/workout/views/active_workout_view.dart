import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/effects/top_progressive_blur.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/views/workout_completion_flow.dart';
import 'package:floww/core/workout/widgets/active_exercise_hero_card.dart';
import 'package:floww/core/workout/widgets/active_metric_pill.dart';
import 'package:floww/core/workout/widgets/active_workout_action_bar.dart';
import 'package:floww/core/workout/widgets/active_workout_progress_header.dart';
import 'package:floww/core/workout/widgets/exercise_info_section_card.dart';
import 'package:floww/core/workout/widgets/rest_timer_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final actionsBottom = viewPadding.bottom + AppSpacing.xl;

    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.shouldStartCompletion) {
          viewModel.markCompletionStarted();
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => WorkoutCompletionFlow.start(
              context: context,
              viewModel: viewModel.completionViewModel(),
            ),
          );
        }
        final session = viewModel.session;

        return Scaffold(
          backgroundColor: context.colors.backgroundPrimary,
          body: AppBackground(
            mode: AppBackgroundMode.flow,
            isInner: true,
            safeAreaTop: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: TopProgressiveBlur(
                    child: ListView(
                      padding: EdgeInsets.only(
                        top:
                            viewPadding.top +
                            kToolbarHeight +
                            _headerBlockHeight +
                            AppSpacing.xl,
                        bottom:
                            actionsBottom + _actionBarHeight + AppSpacing.xl3,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      children: [
                        if (session.isResting)
                          RestTimerCard(
                            secondsLabel: session.restSecondsLabel,
                            onSkip: viewModel.skipRest,
                          )
                        else
                          _ExerciseContent(
                            exercise: session.exercise,
                            onToggleSection: viewModel.toggleSection,
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
                        onClosePressed: _exit,
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
        );
      },
    );
  }
}

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({
    required this.exercise,
    required this.onToggleSection,
  });

  final ActiveExerciseItem exercise;
  final ValueChanged<String> onToggleSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActiveExerciseHeroCard(exercise: exercise),
        SizedBox(height: AppSpacing.xl2),
        SetProgressDots(statuses: exercise.setDots),
        SizedBox(height: AppSpacing.xl2),
        Align(
          child: ActiveMetricPill(
            icon: Icons.track_changes,
            value: exercise.repsInReserveValue,
            label: exercise.repsInReserveLabel,
          ),
        ),
        SizedBox(height: AppSpacing.xl3),
        for (var i = 0; i < exercise.infoSections.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          ExerciseInfoSectionCard(
            section: exercise.infoSections[i],
            onToggle: () => onToggleSection(exercise.infoSections[i].id),
          ),
        ],
      ],
    );
  }
}
