import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/core/nutrition/widgets/nutrition_section_label.dart';
import 'package:floww/config/theme/app_shapes.dart';

class RecentFoodLogsSection extends StatelessWidget {
  const RecentFoodLogsSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<RecentFoodItem> items;
  final ValueChanged<RecentFoodItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutritionSectionLabel(label: 'Recent food logs'),
        SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                _RecentFoodChip(item: items[i], onTap: () => onTap(items[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentFoodChip extends StatelessWidget {
  const _RecentFoodChip({required this.item, required this.onTap});

  final RecentFoodItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppSizes.s128),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle),
        ),
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
              item.caloriesLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: AppShapes.decoration(
                color: colors.backgroundElevated,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.meal.icon,
                    color: item.meal.colorOf(context),
                    size: AppSizes.s10,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(item.meal.label, style: context.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
