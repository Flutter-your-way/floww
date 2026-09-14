import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
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
        variant: AppCardVariant.highlighted,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Nutrition Report',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: context.colors.textSecondary,
                        size: AppSizes.s16,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        rangeLabel,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textSecondary,
              size: AppSizes.s24,
            ),
          ],
        ),
      ),
    );
  }
}
