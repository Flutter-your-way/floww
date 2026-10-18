import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/yoga/models/yoga_class_view_data.dart';

class YogaSectionTimeline extends StatelessWidget {
  const YogaSectionTimeline({super.key, required this.sections});

  final List<YogaSectionChipItem> sections;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final section in sections) _SectionChip(section: section),
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.section});

  final YogaSectionChipItem section;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = section.status == WorkoutSectionStatus.active;
    final isDone = section.status == WorkoutSectionStatus.completed;
    final foreground = isActive
        ? colors.primary
        : isDone
        ? colors.textSecondary
        : colors.textTertiary;

    return AnimatedContainer(
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: AppShapes.decoration(
        color: isActive ? colors.bgTinted : colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isActive ? colors.primary : colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone) ...[
            Icon(Icons.check_rounded, size: AppSizes.s14, color: foreground),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            section.label,
            style: AppTypography.captionSemiBold.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
