import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

enum AppStatusChipVariant { solid, outlined }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppStatusChipVariant.solid,
    this.height = AppSizes.s28,
    this.horizontalPadding = AppSpacing.md,
    this.labelStyle,
    this.isExpanded = false,
  });

  final String label;
  final IconData? icon;
  final AppStatusChipVariant variant;
  final double height;
  final double horizontalPadding;
  final TextStyle? labelStyle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;
    final isSolid = variant == AppStatusChipVariant.solid;
    final foreground = isSolid ? colors.backgroundPrimary : colors.primary;

    return Container(
      height: height,
      width: isExpanded ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: isExpanded ? Alignment.center : null,
      decoration: AppShapes.decoration(
        color: isSolid ? colors.primary : colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: isSolid
            ? BorderSide.none
            : BorderSide(color: colors.borderAccent, width: AppSizes.s1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.s14, color: foreground),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: (labelStyle ?? AppTypography.bodySmallExtraBold).copyWith(
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
