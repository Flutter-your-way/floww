import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_stat_tile.dart';

class HabitStatGrid extends StatelessWidget {
  const HabitStatGrid({super.key, required this.items});

  static const int _columns = 2;

  final List<HabitStatItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index += _columns) ...[
          if (index > 0)
            Divider(
              height: AppSpacing.xl4,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Tile(item: items[index])),
                VerticalDivider(
                  width: AppSpacing.xl3,
                  thickness: AppSizes.s1,
                  color: colors.borderSubtle,
                ),
                Expanded(
                  child: index + 1 < items.length
                      ? _Tile(item: items[index + 1])
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

class _Tile extends StatelessWidget {
  const _Tile({required this.item});

  final HabitStatItem item;

  @override
  Widget build(BuildContext context) {
    return HabitStatTile(
      icon: item.icon,
      label: item.title,
      value: item.value,
      unit: item.unit,
    );
  }
}
