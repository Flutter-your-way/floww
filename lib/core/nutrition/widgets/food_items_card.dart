import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/swipe_to_delete.dart';

class FoodItemsCard extends StatelessWidget {
  const FoodItemsCard({
    super.key,
    required this.items,
    required this.countLabel,
    required this.emptyMessage,
    this.onDelete,
    this.onAdd,
  });

  final List<FoodItemData> items;
  final String countLabel;
  final String emptyMessage;
  final ValueChanged<String>? onDelete;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final onAdd = this.onAdd;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Food Items',
            trailing: Text(
              countLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                emptyMessage,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.borderSubtle,
              ),
            SwipeToDelete(
              id: items[i].id,
              onDelete: onDelete,
              child: _FoodItemRow(item: items[i]),
            ),
          ],
          if (onAdd != null) ...[
            SizedBox(height: AppSpacing.lg),
            PillButton(
              variant: PillButtonVariant.neutral,
              label: 'Add Food Item',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}

class _FoodItemRow extends StatelessWidget {
  const _FoodItemRow({required this.item});

  final FoodItemData item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSizes.s40,
            height: AppSizes.s40,
            decoration: BoxDecoration(
              color: colors.backgroundElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isScanned
                  ? Icons.photo_camera_outlined
                  : Icons.restaurant_rounded,
              color: colors.textSecondary,
              size: AppSizes.s20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.servingLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.caloriesLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    'kcal',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    item.proteinLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.proteinAccent,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    item.carbsLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.accentOrange,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    item.fatLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.fatAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
