import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class PrivacyLinksCard extends StatelessWidget {
  const PrivacyLinksCard({super.key, required this.links, this.onLinkTap});

  final List<PrivacyLinkItem> links;
  final ValueChanged<PrivacyLinkItem>? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onLinkTap = this.onLinkTap;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final link in links) ...[
            if (link != links.first)
              Divider(
                height: AppSpacing.xl3,
                thickness: AppSizes.s1,
                color: colors.borderSubtle,
              ),
            _PrivacyLinkRow(
              link: link,
              onTap: onLinkTap == null ? null : () => onLinkTap(link),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyLinkRow extends StatelessWidget {
  const _PrivacyLinkRow({required this.link, this.onTap});

  final PrivacyLinkItem link;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Row(
        children: [
          AppIconTile(icon: link.icon),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  link.subtitle,
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
