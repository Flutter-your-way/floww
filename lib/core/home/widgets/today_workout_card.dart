import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/home/widgets/home_card_empty_state.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/theme/app_shapes.dart';

class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({super.key, this.workout, this.onStartWorkout});

  final WorkoutRecommendation? workout;
  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final workout = this.workout;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: "Today's Workout"),
          SizedBox(height: AppSpacing.xl),
          if (workout == null)
            HomeCardEmptyState(
              icon: Icons.directions_run,
              message: 'No workout planned yet. Start your first session now.',
              buttonText: 'START WORKOUT',
              buttonIcon: Icons.play_arrow,
              filled: true,
              onPressed: onStartWorkout,
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: AppSizes.s40,
                  width: AppSizes.s40,
                  decoration: AppShapes.decoration(
                    color: context.colors.backgroundElevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: context.colors.textPrimary,
                    size: AppSizes.s20,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.title, style: context.textTheme.titleLarge),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: AppSizes.s14,
                            color: context.colors.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            workout.durationLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Icon(
                            Icons.bolt,
                            size: AppSizes.s14,
                            color: context.colors.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            workout.intensityLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: AppShapes.decoration(
                color: context.colors.tint,
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: context.colors.borderGlow, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended by WAVE because:',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  for (final reason in workout.reasons)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: AppSizes.s16,
                            color: context.colors.primary,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(reason, style: context.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'START WORKOUT',
              icon: Icons.play_arrow,
              backgroundColor: context.colors.textPrimary,
              foregroundColor: context.colors.backgroundPrimary,
              onPressed: onStartWorkout,
            ),
          ],
        ],
      ),
    );
  }
}
