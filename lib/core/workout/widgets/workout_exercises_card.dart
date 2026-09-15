import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_detail.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_exercise_row.dart';

class WorkoutExercisesCard extends StatelessWidget {
  const WorkoutExercisesCard({
    super.key,
    required this.sections,
    required this.countLabel,
    this.onToggleSection,
    this.onAddExercise,
  });

  final List<WorkoutSectionItem> sections;
  final String countLabel;
  final ValueChanged<String>? onToggleSection;
  final VoidCallback? onAddExercise;

  @override
  Widget build(BuildContext context) {
    final onToggleSection = this.onToggleSection;
    final onAddExercise = this.onAddExercise;
    final horizontalPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

    return AppCard(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: horizontalPadding,
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
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const _CardDivider(),
            _ExerciseSection(
              section: sections[i],
              onToggle: onToggleSection == null
                  ? null
                  : () => onToggleSection(sections[i].id),
            ),
          ],
          if (onAddExercise != null) ...[
            const _CardDivider(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: PillButton(
                variant: PillButtonVariant.bright,
                height: AppSizes.s48,
                label: 'ADD EXERCISE',
                icon: Icons.add_circle,
                iconColor: context.colors.onSurfaceBright,
                labelStyle: AppTypography.labelSmallSemiBold,
                onPressed: onAddExercise,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: AppSizes.s1, color: context.colors.borderSubtle);
  }
}

class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({required this.section, this.onToggle});

  final WorkoutSectionItem section;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${section.glyph} ${section.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        section.countLabel,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                _SectionStatusDot(status: section.status),
                SizedBox(width: AppSpacing.lg),
                Icon(
                  section.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.chevron_right,
                  size: AppSizes.s24,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (section.isExpanded)
          for (var i = 0; i < section.exercises.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: const _CardDivider(),
              ),
            WorkoutExerciseRow(
              exercise: section.exercises[i],
              imageUrl: section.exercises[i].imageUrl,
            ),
          ],
      ],
    );
  }
}

class _SectionStatusDot extends StatelessWidget {
  const _SectionStatusDot({required this.status});

  static const double _size = AppSizes.s24;

  final WorkoutSectionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return switch (status) {
      WorkoutSectionStatus.completed => Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.tint,
          border: Border.all(color: colors.primary, width: AppSizes.s2),
        ),
        child: Icon(Icons.check, size: AppSizes.s14, color: colors.primary),
      ),
      WorkoutSectionStatus.active => Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
        ),
      ),
      WorkoutSectionStatus.pending => Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.backgroundElevated,
        ),
      ),
    };
  }
}
