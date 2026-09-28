import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/app_toggle.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class AppToggleCard extends StatelessWidget {
  const AppToggleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          Icon(icon, size: AppSizes.s24, color: colors.textPrimary),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMediumMedium.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
