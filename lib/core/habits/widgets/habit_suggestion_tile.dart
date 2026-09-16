import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_icon.dart';

class HabitSuggestionTile extends StatelessWidget {
  const HabitSuggestionTile({super.key, required this.item, this.onSelect});

  final HabitSuggestionItem item;
  final void Function(HabitSuggestionItem item)? onSelect;

  void _select() {
    HapticManager.light();
    onSelect?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onSelect == null ? null : _select,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: AppCardVariant.subtle,
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: AppSizes.s40,
              height: AppSizes.s40,
              alignment: Alignment.center,
              decoration: AppShapes.decoration(
                color: colors.bgTinted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: colors.borderGlow),
              ),
              child: HabitIcon(
                kind: item.icon,
                size: AppSizes.s20,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLargeSemiBold,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.targetLabel,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmallMediumTight.copyWith(
                      color: colors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitSuggestionGrid extends StatelessWidget {
  const HabitSuggestionGrid({super.key, required this.items, this.onSelect});

  final List<HabitSuggestionItem> items;
  final void Function(HabitSuggestionItem item)? onSelect;

  @override
  Widget build(BuildContext context) {
    final onSelect = this.onSelect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index += 2) ...[
          if (index > 0) SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: HabitSuggestionTile(
                    item: items[index],
                    onSelect: onSelect,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: index + 1 < items.length
                      ? HabitSuggestionTile(
                          item: items[index + 1],
                          onSelect: onSelect,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
