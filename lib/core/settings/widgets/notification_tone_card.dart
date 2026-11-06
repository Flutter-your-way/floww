import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class NotificationToneCard extends StatelessWidget {
  const NotificationToneCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Icon(
              Icons.music_note_rounded,
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
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              valueLabel,
              style: AppTypography.bodySmallSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.s20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
