import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';

class ExercisePickerRow extends StatelessWidget {
  const ExercisePickerRow({super.key, required this.exercise, this.onTap});

  final AddExercisePickerItem exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = exercise.isSelected;

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: isSelected
              ? BorderSide(color: colors.primary, width: AppSizes.s1)
              : BorderSide.none,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                      color: isSelected ? colors.primaryAlt : colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    exercise.detailLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (exercise.isCustom) ...[
              SizedBox(width: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: AppShapes.decoration(
                  color: colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  'CUSTOM',
                  style: AppTypography.captionSemiBold.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
            SizedBox(width: AppSpacing.md),
            Container(
              width: AppSizes.s24,
              height: AppSizes.s24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.tint : colors.backgroundElevated,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.borderSubtle,
                  width: AppSizes.s2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: AppSizes.s14,
                      color: colors.primary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
