import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';

class WeekdayPickerItem {
  const WeekdayPickerItem({
    required this.weekday,
    required this.label,
    required this.isSelected,
  });

  final int weekday;
  final String label;
  final bool isSelected;
}

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({super.key, required this.items, required this.onToggle});

  final List<WeekdayPickerItem> items;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _WeekdayChip(
              item: items[index],
              onTap: () {
                HapticManager.selection();
                onToggle(items[index].weekday);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({required this.item, required this.onTap});

  final WeekdayPickerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppSizes.s40,
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: item.isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: item.isSelected ? colors.borderGlow : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Text(
          item.label,
          style: AppTypography.labelLargeMedium.copyWith(
            color: item.isSelected ? colors.primaryAlt : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
