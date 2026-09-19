import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';

class SuggestedWorkoutCard extends StatelessWidget {
  const SuggestedWorkoutCard({
    super.key,
    required this.title,
    required this.suggestion,
    this.onStartWorkout,
  });

  final String title;
  final WorkoutSuggestionItem suggestion;
  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: title),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkoutIconTile(),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: AppTypography.heading4SemiBold.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _WorkoutMetaRow(
                      durationLabel: suggestion.durationLabel,
                      intensityLabel: suggestion.intensityLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _SuggestionReasons(reasons: suggestion.reasons),
          SizedBox(height: AppSpacing.lg),
          CustomButton(
            text: 'START WORKOUT',
            icon: Icons.play_arrow,
            backgroundColor: context.colors.textPrimary,
            foregroundColor: context.colors.backgroundPrimary,
            onPressed: onStartWorkout,
          ),
        ],
      ),
    );
  }
}

class _WorkoutMetaRow extends StatelessWidget {
  const _WorkoutMetaRow({
    required this.durationLabel,
    required this.intensityLabel,
  });

  final String durationLabel;
  final String intensityLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WorkoutMetaItem(icon: Icons.access_time, label: durationLabel),
        SizedBox(width: AppSpacing.lg),
        _WorkoutMetaItem(icon: Icons.bolt, label: intensityLabel),
      ],
    );
  }
}

class _WorkoutMetaItem extends StatelessWidget {
  const _WorkoutMetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.s16, color: color),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmallRegularTight.copyWith(color: color),
        ),
      ],
    );
  }
}

class _SuggestionReasons extends StatelessWidget {
  const _SuggestionReasons({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
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
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          for (final reason in reasons)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: AppSizes.s20,
                    color: context.colors.primary,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      reason,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
