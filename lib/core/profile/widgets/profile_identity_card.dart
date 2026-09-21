import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';
import 'package:floww/core/profile/widgets/profile_avatar_image.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.summary,
    required this.badgeLabel,
    this.onAvatarTap,
  });

  final ProfileSummary summary;
  final String badgeLabel;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: summary.isPremium ? AppCardVariant.glow : AppCardVariant.plain,
      borderColor: summary.isPremium ? colors.borderGlow : null,
      child: Row(
        children: [
          PressScale(
            onTap: summary.avatarUrl == null ? null : onAvatarTap,
            child: ProfileAvatarImage(
              initial: summary.initial,
              imageUrl: summary.avatarUrl,
            ),
          ),
          SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading3Bold,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  summary.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          if (summary.isPremium) ...[
            SizedBox(width: AppSpacing.md),
            AppStatusChip(
              label: badgeLabel,
              icon: Icons.workspace_premium_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
