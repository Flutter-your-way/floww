import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/weekly_report_cards.dart';

class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({
    super.key,
    required this.summary,
    required this.statuses,
    this.onTap,
  });

  final String summary;
  final List<DayStatusItem> statuses;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: AppCardVariant.tinted,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This week',
                  style: AppTypography.labelMediumSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  summary,
                  style: AppTypography.labelSmallRegular.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final item in statuses)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DayStatusDot(status: item.status, size: AppSizes.s10),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          item.label,
                          style: AppTypography.labelSmallRegular.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: AppSizes.s16,
            ),
          ],
        ),
      ),
    );
  }
}
