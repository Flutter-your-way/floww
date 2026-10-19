import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/images/image_precacher.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_card.dart';
import 'package:floww/core/workout/view_models/todays_workout_view_model.dart';
import 'package:floww/core/workout/widgets/todays_workout_exercises_card.dart';
import 'package:floww/core/workout/widgets/todays_workout_summary_card.dart';
import 'package:floww/core/workout/widgets/workout_empty_state_card.dart';
import 'package:floww/core/workout/widgets/workout_shift_card.dart';
import 'package:floww/core/yoga/views/yoga_safety_sheet.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class TodaysWorkoutView extends StatelessWidget {
  const TodaysWorkoutView({super.key});

  Future<void> _onAction(
    BuildContext context,
    TodaysWorkoutViewModel viewModel,
  ) async {
    final sessionId = viewModel.sessionId;
    if (viewModel.action == TodaysWorkoutAction.viewSummary &&
        sessionId != null) {
      HapticManager.light();
      NavigationService.instance.push(
        AppRouter.workoutDetails,
        arguments: sessionId,
      );
      return;
    }
    if (await viewModel.needsSafetyCheck()) {
      if (!context.mounted) return;
      final accepted = await YogaSafetySheet.show(context);
      if (!accepted) return;
      await viewModel.acknowledgeSafety();
    }
    HapticManager.medium();
    NavigationService.instance.push(
      AppRouter.activeWorkout,
      arguments: viewModel.activeWorkoutArgs,
    );
  }

  void _openCatchUp(TodaysWorkoutViewModel viewModel) {
    final args = viewModel.catchUpArgs;
    if (args == null) return;
    HapticManager.medium();
    NavigationService.instance.push(AppRouter.todaysWorkout, arguments: args);
  }

  void _openCourse() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.yogaCourse);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodaysWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final workout = viewModel.workout;
        final errorMessage = viewModel.errorMessage;

        return ImagePrecacher(
          urls: viewModel.imageUrls,
          child: InnerPageScaffold(
            title: viewModel.title,
            onBack: () => NavigationService.instance.pop(),
            footer: workout == null
                ? null
                : PillButton(
                    variant: viewModel.isCompleted || viewModel.isLocked
                        ? PillButtonVariant.neutral
                        : PillButtonVariant.primary,
                    label: viewModel.startLabel,
                    onPressed: viewModel.isLocked
                        ? null
                        : () => _onAction(context, viewModel),
                  ),
            children: [
              if (viewModel.isLoading)
                const AppSectionLoader()
              else if (errorMessage != null)
                AppErrorCard(message: errorMessage, onRetry: viewModel.load)
              else ...[
                if (viewModel.canShift) ...[
                  PremiumGate(
                    capability: PremiumCapability.adaptiveEngine,
                    placeholder: const SizedBox.shrink(),
                    locked: PremiumLockedCard(
                      capability: PremiumCapability.adaptiveEngine,
                      title: viewModel.shiftTitle,
                    ),
                    child: WorkoutShiftCard(
                      title: viewModel.shiftTitle,
                      message: viewModel.shiftMessage,
                      actionLabel: viewModel.shiftLabel,
                      isLoading: viewModel.isShifting,
                      onAction: () {
                        HapticManager.medium();
                        viewModel.shiftSchedule();
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (viewModel.hasPendingCatchUp) ...[
                  WorkoutShiftCard(
                    title: viewModel.catchUpTitle,
                    message: viewModel.catchUpMessage,
                    actionLabel: viewModel.catchUpActionLabel,
                    onAction: () => _openCatchUp(viewModel),
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (viewModel.isLocked) ...[
                  TipCard(
                    title: viewModel.lockedMessage,
                    icon: Icons.lock_clock_rounded,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (workout == null)
                  WorkoutEmptyStateCard(
                    icon: viewModel.emptyIcon,
                    title: viewModel.emptyTitle,
                    message: viewModel.emptyMessage,
                  )
                else ...[
                  TodaysWorkoutSummaryCard(workout: workout),
                  SizedBox(height: AppSpacing.lg),
                  TodaysWorkoutExercisesCard(
                    exercises: workout.exercises,
                    countLabel: workout.exerciseCountLabel,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TipCard.note(title: workout.insight),
                  if (viewModel.isYogaClass) ...[
                    SizedBox(height: AppSpacing.lg),
                    PillButton(
                      variant: PillButtonVariant.outline,
                      label: viewModel.courseLabel,
                      icon: Icons.self_improvement,
                      onPressed: _openCourse,
                    ),
                  ],
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
