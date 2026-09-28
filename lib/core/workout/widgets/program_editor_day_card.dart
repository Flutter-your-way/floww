import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/workout/models/program_editor_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ProgramEditorDayCard extends StatelessWidget {
  const ProgramEditorDayCard({
    super.key,
    required this.day,
    required this.nameHint,
    required this.addLabel,
    required this.onRename,
    required this.onEditExercise,
    required this.onAddExercise,
  });

  final ProgramEditorDayItem day;
  final String nameHint;
  final String addLabel;
  final ValueChanged<String> onRename;
  final ValueChanged<int> onEditExercise;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.weekdayLabel,
                  style: AppTypography.captionSemiBold.copyWith(
                    color: colors.primaryAlt,
                  ),
                ),
              ),
              Text(
                day.summaryLabel,
                style: AppTypography.labelSmallMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          CompactTextField(
            key: ValueKey('program-day-${day.weekday}'),
            hintText: nameHint,
            initialText: day.name,
            textCapitalization: TextCapitalization.words,
            onChanged: onRename,
          ),
          if (day.exercises.isNotEmpty) SizedBox(height: AppSpacing.md),
          for (final exercise in day.exercises)
            _EditorExerciseRow(
              exercise: exercise,
              onTap: () => onEditExercise(exercise.index),
            ),
          SizedBox(height: AppSpacing.lg),
          PillButton(
            variant: PillButtonVariant.outline,
            height: AppSizes.s44,
            label: addLabel,
            icon: Icons.add_rounded,
            onPressed: onAddExercise,
          ),
        ],
      ),
    );
  }
}

class _EditorExerciseRow extends StatelessWidget {
  const _EditorExerciseRow({required this.exercise, required this.onTap});

  final ProgramEditorExerciseItem exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          children: [
            Text(exercise.glyph, style: AppTypography.bodyMediumMedium),
            SizedBox(width: AppSpacing.md),
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
            SizedBox(width: AppSpacing.md),
            WorkoutChip(label: exercise.targetLabel),
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.s20,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
