import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/missed_workout_advice.dart';
import 'package:floww/core/workout/widgets/workout_metric_row.dart';

class MissedWorkoutSheet extends StatelessWidget {
  const MissedWorkoutSheet({super.key, required this.missed, this.onAction});

  static Future<void> show({
    required BuildContext context,
    required MissedWorkoutItem missed,
    VoidCallback? onAction,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => MissedWorkoutSheet(missed: missed, onAction: onAction),
    );
  }

  final MissedWorkoutItem missed;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionLabel = missed.actionLabel;
    final onAction = this.onAction;

    return AppFloatingSheet(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: missed.name,
              subtitle: 'Missed · ${missed.dateLabel}',
            ),
            SizedBox(height: AppSpacing.xl),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (missed.detailLabel.isNotEmpty) ...[
                      Text(
                        missed.detailLabel,
                        style: AppTypography.labelSmallMedium.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                    ],
                    WorkoutMetricRow(metrics: missed.metrics),
                    if (missed.goal.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xl),
                      Text(
                        missed.goal,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    if (missed.musclesLabel.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xl),
                      const SectionLabel(label: 'Muscles targeted'),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        missed.musclesLabel,
                        style: AppTypography.labelLargeSemiBold.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.xl),
                    SectionLabel(
                      label: 'Planned exercises (${missed.exercises.length})',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    for (var i = 0; i < missed.exercises.length; i++)
                      _MissedExerciseRow(
                        exercise: missed.exercises[i],
                        showDivider: i > 0,
                      ),
                    SizedBox(height: AppSpacing.xl),
                    MissedWorkoutAdvice(missed: missed),
                  ],
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              PillButton(
                label: actionLabel,
                icon: Icons.event_repeat_rounded,
                height: AppSizes.s48,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissedExerciseRow extends StatelessWidget {
  const _MissedExerciseRow({required this.exercise, required this.showDivider});

  final MissedExerciseItem exercise;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                top: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exercise.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMediumMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Text(
            exercise.targetLabel,
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
