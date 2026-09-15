import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class WeeklyReportCard extends StatelessWidget {
  const WeeklyReportCard({super.key, required this.rangeLabel, this.onTap});

  final String rangeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: AppCardVariant.tinted,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Nutrition Report',
                    style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: context.colors.textSecondary,
                        size: AppSizes.s12,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        rangeLabel,
                        style: AppTypography.bodySmallMediumTight.copyWith(
                          color: context.colors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.xl),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textSecondary,
              size: AppSizes.s16,
            ),
          ],
        ),
      ),
    );
  }
}
