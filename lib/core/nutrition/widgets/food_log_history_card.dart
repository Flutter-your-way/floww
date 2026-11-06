import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/food_photo.dart';
import 'package:floww/core/nutrition/widgets/swipe_to_delete.dart';

class FoodLogHistoryCard extends StatelessWidget {
  const FoodLogHistoryCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.canDelete,
    this.onDelete,
  });

  final FoodLogHistoryGroup group;
  final ValueChanged<FoodLogHistoryItem> onTap;
  final bool Function(FoodLogHistoryItem item) canDelete;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final items = group.items;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: group.dateLabel,
            trailing: Text(
              group.totalLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.borderSubtle,
              ),
            SwipeToDelete(
              id: items[i].id,
              onDelete: canDelete(items[i]) ? onDelete : null,
              child: _HistoryRow(item: items[i], onTap: () => onTap(items[i])),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.onTap});

  final FoodLogHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return PressScale(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            FoodPhoto(name: item.name),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium,
                  ),
                  Text(
                    item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: captionStyle,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.caloriesLabel, style: context.textTheme.labelMedium),
                Text(item.timeLabel, style: captionStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
