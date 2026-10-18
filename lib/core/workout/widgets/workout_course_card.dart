import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/workout/models/workout_course_view_data.dart';

class WorkoutCourseCard extends StatelessWidget {
  const WorkoutCourseCard({
    super.key,
    required this.course,
    required this.onAction,
  });

  final WorkoutCourseItem course;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeLabel = course.badgeLabel;

    return AppCard(
      variant: AppCardVariant.glow,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.eyebrow,
                  style: AppTypography.labelSmallSemiBold.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
              if (badgeLabel != null) AppStatusChip(label: badgeLabel),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            course.title,
            style: AppTypography.heading4SemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            course.subtitle,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _SegmentBar(segments: course.segments),
          for (final fact in course.facts) ...[
            SizedBox(height: AppSpacing.lg),
            _FactRow(fact: fact),
          ],
          SizedBox(height: AppSpacing.xl),
          PillButton(
            variant: PillButtonVariant.outline,
            label: course.actionLabel,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.segments});

  final List<WorkoutCourseSegmentState> segments;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Container(
              height: AppSizes.s6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: switch (segments[i]) {
                  WorkoutCourseSegmentState.done => colors.primaryDeep,
                  WorkoutCourseSegmentState.current => colors.primary,
                  WorkoutCourseSegmentState.upcoming => colors.borderSubtle,
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final WorkoutCourseFact fact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(fact.icon, size: AppSizes.s18, color: colors.primary),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            fact.text,
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
