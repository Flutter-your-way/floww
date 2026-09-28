import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class ActiveOptionRow extends StatelessWidget {
  const ActiveOptionRow({super.key, required this.option, this.onTap});

  final ActiveOptionItem option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = !option.isEnabled
        ? colors.textFaint
        : option.isDestructive
        ? colors.destructive
        : colors.textPrimary;

    return PressScale(
      onTap: option.isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(option.icon, size: AppSizes.s20, color: color),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMediumSemiBold.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
