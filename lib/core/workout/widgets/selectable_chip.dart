import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl2,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: isSelected
              ? BorderSide(color: colors.primary, width: AppSizes.s1)
              : BorderSide.none,
        ),
        child: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(
            color: isSelected ? colors.primaryAlt : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
