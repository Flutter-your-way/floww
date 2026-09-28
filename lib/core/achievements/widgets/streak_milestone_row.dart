import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/achievements/models/streak_milestone.dart';

class StreakMilestoneRow extends StatelessWidget {
  const StreakMilestoneRow({super.key, required this.milestone});

  final StreakMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        _MilestoneBadge(emoji: milestone.emoji),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                milestone.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                milestone.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s36,
      width: AppSizes.s36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.backgroundSurface,
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: context.textTheme.bodyLarge),
    );
  }
}
