import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.summary,
    required this.badgeLabel,
  });

  final ProfileSummary summary;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: summary.isPremium ? AppCardVariant.glow : AppCardVariant.plain,
      borderColor: summary.isPremium ? colors.borderGlow : null,
      child: Row(
        children: [
          _ProfileAvatarTile(
            initial: summary.initial,
            avatarUrl: summary.avatarUrl,
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
                  style: AppTypography.labelMediumRegular.copyWith(
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

class _ProfileAvatarTile extends StatelessWidget {
  const _ProfileAvatarTile({required this.initial, this.avatarUrl});

  final String initial;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarUrl = this.avatarUrl;
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    return Container(
      height: AppSizes.s60,
      width: AppSizes.s60,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: AppShapes.decoration(
        color: colors.bgTinted,
        borderRadius: borderRadius,
        side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
      ),
      child: avatarUrl == null
          ? Text(
              initial,
              style: AppTypography.heading2Bold.copyWith(color: colors.primary),
            )
          : Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              width: AppSizes.s60,
              height: AppSizes.s60,
              errorBuilder: (context, error, stackTrace) => Text(
                initial,
                style: AppTypography.heading2Bold.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
    );
  }
}
