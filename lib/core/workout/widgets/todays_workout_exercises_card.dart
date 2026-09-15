import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_exercise_row.dart';

class TodaysWorkoutExercisesCard extends StatelessWidget {
  const TodaysWorkoutExercisesCard({
    super.key,
    required this.exercises,
    required this.countLabel,
  });

  final List<WorkoutExerciseItem> exercises;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: CardHeader(
              title: 'Exercises',
              trailing: Text(
                countLabel,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          for (var i = 0; i < exercises.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  height: AppSizes.s1,
                  color: context.colors.borderSubtle,
                ),
              ),
            WorkoutExerciseRow(
              exercise: exercises[i],
              imageUrl: exercises[i].imageUrl,
            ),
          ],
        ],
      ),
    );
  }
}
