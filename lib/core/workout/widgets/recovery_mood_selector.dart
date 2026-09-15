import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';

class RecoveryMoodSelector extends StatelessWidget {
  const RecoveryMoodSelector({
    super.key,
    required this.moods,
    required this.selected,
    required this.onSelected,
  });

  final List<RecoveryMoodItem> moods;
  final RecoveryMood? selected;
  final ValueChanged<RecoveryMood> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < moods.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _RecoveryMoodTile(
              mood: moods[i],
              isSelected: moods[i].mood == selected,
              onTap: () => onSelected(moods[i].mood),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecoveryMoodTile extends StatelessWidget {
  const _RecoveryMoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final RecoveryMoodItem mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xl,
        ),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.glyph, style: AppTypography.heading3Bold),
            SizedBox(height: AppSpacing.md),
            Text(
              mood.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMediumMedium.copyWith(
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
