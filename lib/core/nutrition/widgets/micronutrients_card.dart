import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class MicronutrientsCard extends StatelessWidget {
  const MicronutrientsCard({
    super.key,
    required this.limits,
    required this.summaryLabel,
    required this.onTap,
  });

  final List<MicronutrientRowItem> limits;
  final String summaryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CardHeader(title: 'Micronutrients', showChevron: true),
            SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < limits.length; i++) ...[
                  if (i > 0) SizedBox(width: AppSpacing.lg),
                  Expanded(child: _LimitColumn(item: limits[i])),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.eco_rounded,
                  size: AppSizes.s14,
                  color: colors.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    summaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitColumn extends StatelessWidget {
  const _LimitColumn({required this.item});

  final MicronutrientRowItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.label, style: captionStyle),
        SizedBox(height: AppSpacing.xxs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            item.amountLabel,
            maxLines: 1,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: item.isOverLimit
                  ? colors.destructiveBorder
                  : colors.textPrimary,
            ),
          ),
        ),
        Text(
          '/ ${item.goalLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.textMuted,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(progress: item.progress, animated: true),
      ],
    );
  }
}
