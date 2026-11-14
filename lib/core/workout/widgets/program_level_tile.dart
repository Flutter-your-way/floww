import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_photo_card.dart';

class ProgramLevelTile extends StatelessWidget {
  const ProgramLevelTile({super.key, required this.level, this.onTap});

  final ProgramLevelCardItem level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return WorkoutPhotoCard(
      imageUrl: level.imageUrl,
      onTap: onTap,
      radius: AppRadius.lg,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      topTrailing: level.isCurrent ? const _CurrentLevelBadge() : null,
      child: Text(
        level.title.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.photoTileTitle.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

class _CurrentLevelBadge extends StatelessWidget {
  const _CurrentLevelBadge();

  static const String _label = 'YOUR LEVEL';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: AppShapes.decoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _label,
        style: AppTypography.captionSemiBold.copyWith(
          color: colors.backgroundPrimary,
        ),
      ),
    );
  }
}
