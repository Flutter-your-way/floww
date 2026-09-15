import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';

enum WorkoutChipTone { muted, accent, filled }

class WorkoutChip extends StatelessWidget {
  const WorkoutChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = WorkoutChipTone.muted,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final WorkoutChipTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;
    final isAccent = tone == WorkoutChipTone.accent;
    final isFilled = tone == WorkoutChipTone.filled;
    final foreground = switch (tone) {
      WorkoutChipTone.muted => colors.textSecondary,
      WorkoutChipTone.accent => colors.primaryAlt,
      WorkoutChipTone.filled => colors.backgroundPrimary,
    };

    final chip = Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: AppShapes.decoration(
            color: isFilled ? colors.primaryAlt : colors.borderSubtle,
            borderRadius: BorderRadius.circular(AppRadius.full),
            side: isFilled
                ? BorderSide.none
                : BorderSide(
                    color: isAccent
                        ? colors.borderMedium
                        : colors.surfaceTranslucent,
                    width: AppSizes.s1,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.captionSemiBold.copyWith(
                  color: foreground,
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: AppSpacing.xxs),
                Icon(icon, size: AppSizes.s12, color: foreground),
              ],
            ],
          ),
        ),
        if (isAccent)
          Positioned.fill(
            child: InnerGlow(
              color: colors.textPrimary.withValues(alpha: AppOpacity.softGlow),
              radius: AppRadius.full,
            ),
          ),
      ],
    );

    if (onTap == null) return chip;
    return PressScale(onTap: onTap, child: chip);
  }
}
