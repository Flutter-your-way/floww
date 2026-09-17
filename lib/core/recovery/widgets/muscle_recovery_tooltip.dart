import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';

class MuscleRecoveryTooltip extends StatelessWidget {
  const MuscleRecoveryTooltip({super.key, required this.item});

  final MuscleRecoveryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = item.status.highlightColor(colors);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        shadows: [
          BoxShadow(
            color: accent.withValues(alpha: AppOpacity.buttonGlow),
            blurRadius: AppSizes.s24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.group.label.toUpperCase(),
            style: AppTypography.bodyLargeBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${item.percent}%',
            style: AppTypography.bodyHeadlineBoldTight.copyWith(color: accent),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            item.status.label.toUpperCase(),
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
