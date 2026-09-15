import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/workout/view_models/todays_workout_view_model.dart';
import 'package:floww/core/workout/widgets/todays_workout_exercises_card.dart';
import 'package:floww/core/workout/widgets/todays_workout_summary_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class TodaysWorkoutView extends StatelessWidget {
  const TodaysWorkoutView({super.key});

  void _startWorkout() {
    HapticManager.medium();
    NavigationService.instance.push(AppRouter.activeWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodaysWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final workout = viewModel.workout;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          footer: PillButton(
            variant: PillButtonVariant.primary,
            label: 'Start Workout',
            onPressed: _startWorkout,
          ),
          children: [
            TodaysWorkoutSummaryCard(workout: workout),
            SizedBox(height: AppSpacing.lg),
            TodaysWorkoutExercisesCard(
              exercises: workout.exercises,
              countLabel: workout.exerciseCountLabel,
            ),
            SizedBox(height: AppSpacing.lg),
            TipCard.note(title: workout.insight),
          ],
        );
      },
    );
  }
}
