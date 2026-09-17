import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/section_label.dart';

class AchievementXpCard extends StatelessWidget {
  const AchievementXpCard({
    super.key,
    required this.totalXp,
    required this.unlockedLabel,
  });

  final int totalXp;
  final String unlockedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.innerGlow,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SectionLabel(label: 'Total XP Earned'),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '$totalXp',
                  style: AppTypography.heading1.copyWith(color: colors.primary),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  unlockedLabel,
                  style: AppTypography.bodyLargeMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xl),
          const _TrophyBadge(),
        ],
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  const _TrophyBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppSizes.s64,
      width: AppSizes.s64,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
      ),
      child: Icon(
        Icons.emoji_events_outlined,
        size: AppSizes.s32,
        color: colors.primary,
      ),
    );
  }
}
