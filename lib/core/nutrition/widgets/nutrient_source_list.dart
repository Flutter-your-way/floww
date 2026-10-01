import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/food_photo.dart';

class NutrientSourceList extends StatelessWidget {
  const NutrientSourceList({
    super.key,
    required this.title,
    required this.items,
    required this.emptyMessage,
    this.isOverLimit = false,
  });

  final String title;
  final List<NutrientSourceItem> items;
  final String emptyMessage;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.sunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                emptyMessage,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(height: 1, thickness: 1, color: colors.borderSubtle),
              _NutrientSourceRow(item: items[i], isOverLimit: isOverLimit),
            ],
        ],
      ),
    );
  }
}

class _NutrientSourceRow extends StatelessWidget {
  const _NutrientSourceRow({required this.item, required this.isOverLimit});

  final NutrientSourceItem item;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final barColor = isOverLimit ? colors.destructiveBorder : null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          FoodPhoto(name: item.name, size: AppSizes.s36),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      item.amountLabel,
                      style: context.textTheme.labelMedium,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      item.shareLabel,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  progress: item.share,
                  color: barColor,
                  height: AppSizes.s4,
                  animated: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
