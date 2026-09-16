import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';

class HabitOptionSheet extends StatelessWidget {
  const HabitOptionSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<HabitOptionItem> items,
    required String selectedId,
    required ValueChanged<String> onSelect,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => HabitOptionSheet(
        title: title,
        subtitle: subtitle,
        items: items,
        selectedId: selectedId,
        onSelect: onSelect,
      ),
    );
  }

  final String title;
  final String subtitle;
  final List<HabitOptionItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;

  void _select(BuildContext context, HabitOptionItem item) {
    HapticManager.selection();
    onSelect(item.id);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        subtitle: subtitle,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              if (index > 0) SizedBox(height: AppSpacing.md),
              HabitOptionRow(
                label: items[index].label,
                isSelected: items[index].id == selectedId,
                onPressed: () => _select(context, items[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HabitOptionRow extends StatelessWidget {
  const HabitOptionRow({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: isSelected ? colors.borderGlow : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLargeMedium.copyWith(
                  color: isSelected ? colors.primaryAlt : colors.textPrimary,
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.check_rounded,
                size: AppSizes.s20,
                color: colors.primaryAlt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
