import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';

class CalPrinciplesHeroCard extends StatelessWidget {
  const CalPrinciplesHeroCard({
    super.key,
    required this.title,
    required this.summary,
    required this.showBadge,
    required this.onOpen,
  });

  static const String _badgeLabel = 'Read once';

  final String title;
  final String summary;
  final bool showBadge;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onOpen,
      child: AppCard(
        variant: AppCardVariant.glow,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            AppIconTile(
              icon: Icons.health_and_safety_outlined,
              size: AppSizes.s56,
              iconSize: AppSizes.s28,
              backgroundColor: colors.bgTinted,
              borderColor: colors.borderAccent,
              iconColor: colors.primary,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading4SemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppMotion.expand,
              child: showBadge
                  ? const AppStatusChip(
                      key: ValueKey(_badgeLabel),
                      label: _badgeLabel,
                      icon: Icons.auto_stories_outlined,
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.s24,
                      color: colors.textSecondary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
