import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/achievements/models/streak_milestone.dart';
import 'package:floww/core/achievements/widgets/achievement_badge.dart';

class StreakMilestoneRow extends StatelessWidget {
  const StreakMilestoneRow({super.key, required this.milestone});

  final StreakMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        AchievementBadge(
          rarity: milestone.tier.rarity,
          isEarned: milestone.isReached,
          icon: Icons.local_fire_department_rounded,
          label: milestone.tier.daysLabel,
          size: AppSizes.s36,
        ),
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
