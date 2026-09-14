import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MicronutrientTiles extends StatelessWidget {
  const MicronutrientTiles({
    super.key,
    required this.items,
    this.onOpenWater,
    this.onAddWater,
  });

  final List<MicronutrientTileItem> items;
  final VoidCallback? onOpenWater;
  final VoidCallback? onAddWater;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(items[i])),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: i + 1 < items.length
                      ? _tile(items[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _tile(MicronutrientTileItem item) {
    final isWater = item.kind == MicronutrientKind.water;
    return _MicronutrientTile(
      item: item,
      onTap: isWater ? onOpenWater : null,
      onAdd: isWater ? onAddWater : null,
    );
  }
}

class _MicronutrientTile extends StatelessWidget {
  const _MicronutrientTile({required this.item, this.onTap, this.onAdd});

  final MicronutrientTileItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAdd = this.onAdd;
    final barColor = item.isOverLimit ? colors.destructiveBorder : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  item.kind.icon,
                  color: colors.textSecondary,
                  size: AppSizes.s16,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    progress: item.progress,
                    color: barColor,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  item.percentLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: barColor ?? colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  item.valueLabel,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.goalLabel,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (onAdd != null)
                  GestureDetector(
                    onTap: onAdd,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '+ Intake',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
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
