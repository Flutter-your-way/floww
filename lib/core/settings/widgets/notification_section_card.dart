import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/app_toggle.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class NotificationSectionCard extends StatelessWidget {
  const NotificationSectionCard({
    super.key,
    required this.section,
    required this.isEnabled,
    this.onChanged,
  });

  final NotificationSection section;
  final bool isEnabled;
  final void Function(String id, bool value)? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: section.title, titleStyle: AppTypography.heading4),
          for (final item in section.items) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
            _NotificationToggleRow(
              item: item,
              isEnabled: isEnabled,
              onChanged: onChanged == null
                  ? null
                  : (value) => onChanged(item.id, value),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.item,
    required this.isEnabled,
    this.onChanged,
  });

  final NotificationToggleItem item;
  final bool isEnabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        const AppIconTile(icon: Icons.notifications_none_rounded),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                item.subtitle,
                style: AppTypography.bodyMediumMedium.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        AppToggle(
          value: item.isEnabled,
          isEnabled: isEnabled,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
