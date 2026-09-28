import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/achievements/models/streak_milestone.dart';
import 'package:floww/core/achievements/widgets/streak_milestone_row.dart';

class StreakMilestonesCard extends StatelessWidget {
  const StreakMilestonesCard({
    super.key,
    required this.milestones,
    required this.onSeeAll,
  });

  final List<StreakMilestone> milestones;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardHeader(
            title: 'Milestones',
            titleStyle: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            onTap: onSeeAll,
            trailing: _SeeAllLink(onTap: onSeeAll),
          ),
          for (final milestone in milestones) ...[
            SizedBox(height: AppSpacing.lg),
            StreakMilestoneRow(milestone: milestone),
            if (milestone != milestones.last) ...[
              SizedBox(height: AppSpacing.lg),
              Container(height: AppSizes.s1, color: colors.borderSubtle),
            ],
          ],
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'All milestones',
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.xxs),
          Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.s16,
            color: colors.primary,
          ),
        ],
      ),
    );
  }
}
