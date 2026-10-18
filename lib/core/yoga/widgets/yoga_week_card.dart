import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';

class YogaWeekCard extends StatelessWidget {
  const YogaWeekCard({super.key, required this.week});

  final YogaWeekItem week;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: week.isCurrent
          ? AppCardVariant.accentOutline
          : AppCardVariant.subtle,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                week.label.toUpperCase(),
                style: AppTypography.labelSmallSemiBold.copyWith(
                  color: week.isCurrent ? colors.primary : colors.textTertiary,
                ),
              ),
              const Spacer(),
              if (week.isCurrent)
                const AppStatusChip(label: 'This week')
              else if (week.isDone)
                Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.s20,
                  color: colors.success,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            week.title,
            style: AppTypography.bodyLargeSemiBoldTight.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            week.summary,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
