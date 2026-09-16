import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';

class ProfileUnitDropdown<T> extends StatelessWidget {
  const ProfileUnitDropdown({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onSelected,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  void _select(T selected) {
    HapticManager.selection();
    onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<T>(
      onSelected: _select,
      initialValue: value,
      color: colors.backgroundElevated,
      elevation: 0,
      position: PopupMenuPosition.under,
      shape: AppShapes.border(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      itemBuilder: (context) => [
        for (final option in values)
          PopupMenuItem<T>(
            value: option,
            height: AppSizes.s40,
            child: Text(
              labelOf(option),
              style: AppTypography.labelLargeMedium.copyWith(
                color: option == value ? colors.primaryAlt : colors.textPrimary,
              ),
            ),
          ),
      ],
      child: Container(
        height: AppSizes.s44,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppShapes.decoration(
          color: colors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(labelOf(value), style: AppTypography.bodyLargeSemiBold),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.s20,
              color: colors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
