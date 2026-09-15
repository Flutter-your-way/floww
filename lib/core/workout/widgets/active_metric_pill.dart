import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class ActiveMetricPill extends StatelessWidget {
  const ActiveMetricPill({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.surfaceTranslucent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderMedium, width: AppSizes.s1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.s16, color: colors.textSecondary),
            SizedBox(width: AppSpacing.sm),
          ],
          Text.rich(
            TextSpan(
              style: AppTypography.bodyMediumMedium.copyWith(
                color: colors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: AppTypography.bodyMediumSemiBold.copyWith(
                    color: colors.primary,
                  ),
                ),
                TextSpan(text: ' $label'),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
