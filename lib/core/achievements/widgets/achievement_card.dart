import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/achievements/models/achievement.dart';
import 'package:floww/core/achievements/widgets/achievement_badge.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnlocked = achievement.isUnlocked;

    return AppCard(
      variant: isUnlocked ? AppCardVariant.subtle : AppCardVariant.plain,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AchievementBadge(
                    rarity: achievement.rarity,
                    isEarned: isUnlocked,
                    icon: achievement.icon,
                    label: achievement.badgeLabel,
                  ),
                ),
              ),
              if (isUnlocked) const _UnlockedCheck(),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLargeBold.copyWith(
              color: isUnlocked ? colors.textPrimary : colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmallMedium.copyWith(
              color: isUnlocked ? colors.textSecondary : colors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _XpPill(label: achievement.xpLabel, isUnlocked: isUnlocked),
        ],
      ),
    );
  }
}

class _UnlockedCheck extends StatelessWidget {
  const _UnlockedCheck();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppSizes.s24,
      width: AppSizes.s24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
      child: Icon(
        Icons.check_rounded,
        size: AppSizes.s16,
        color: colors.backgroundPrimary,
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.label, required this.isUnlocked});

  final String label;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isUnlocked ? colors.primary : colors.textSecondary;

    return Container(
      height: AppSizes.s28,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: AppShapes.decoration(
        color: isUnlocked ? colors.tint : colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isUnlocked ? colors.borderAccent : colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? Icons.bolt_rounded : Icons.lock_rounded,
            size: AppSizes.s14,
            color: foreground.withValues(alpha: AppOpacity.mutedIcon),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmallExtraBold.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
