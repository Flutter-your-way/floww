import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_photo_card.dart';

class ProgramGoalCard extends StatelessWidget {
  const ProgramGoalCard({super.key, required this.goal, this.onTap});

  final ProgramGoalCardItem goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WorkoutPhotoCard(
      imageUrl: goal.imageUrl,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.xl4,
      ),
      topTrailing: goal.isLocked ? const _LockBadge() : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            goal.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.photoCardTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            goal.subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLargeRegular.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: AppSizes.s32,
      height: AppSizes.s32,
      decoration: AppShapes.decoration(
        color: colors.scrim,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Icon(
        Icons.lock_rounded,
        size: AppSizes.s16,
        color: colors.textPrimary,
      ),
    );
  }
}
