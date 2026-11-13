import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
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
