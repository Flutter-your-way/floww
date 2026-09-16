import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  });

  final String title;
  final List<ProfileSettingItem> items;
  final ValueChanged<ProfileSettingItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onItemTap = this.onItemTap;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: AppTypography.heading4),
          for (final item in items) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
            _ProfileSettingRow(
              item: item,
              onTap: onItemTap == null ? null : () => onItemTap(item),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileSettingRow extends StatelessWidget {
  const _ProfileSettingRow({required this.item, this.onTap});

  final ProfileSettingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Row(
        children: [
          _SettingIconTile(icon: item.icon),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  item.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMediumMedium.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.s20,
            color: colors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _SettingIconTile extends StatelessWidget {
  const _SettingIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppIconTile(icon: icon);
  }
}
