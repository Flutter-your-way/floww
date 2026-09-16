import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/app_toggle.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class NotificationMasterCard extends StatelessWidget {
  const NotificationMasterCard({super.key, required this.item, this.onChanged});

  final NotificationToggleItem item;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: AppSizes.s24,
            color: colors.textPrimary,
          ),
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
          AppToggle(value: item.isEnabled, onChanged: onChanged),
        ],
      ),
    );
  }
}
