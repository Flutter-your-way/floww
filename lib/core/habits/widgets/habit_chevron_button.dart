import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class HabitChevronButton extends StatelessWidget {
  const HabitChevronButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppSizes.s40,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppShapes.decoration(
          color: backgroundColor ?? colors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.labelLargeMedium),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.s20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
