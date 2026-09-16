import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class DestructivePillButton extends StatelessWidget {
  const DestructivePillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;

    return PressScale(
      onTap: onPressed,
      child: Container(
        height: AppSizes.s56,
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: colors.destructiveBorder, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.s20, color: colors.destructiveBorder),
              SizedBox(width: AppSpacing.md),
            ],
            Text(
              label,
              style: AppTypography.heading4SemiBold.copyWith(
                color: colors.destructiveBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
