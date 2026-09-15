import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class MuscleActivationRow extends StatelessWidget {
  const MuscleActivationRow({
    super.key,
    required this.muscle,
    this.nameStyle,
    this.valueStyle,
    this.barHeight = AppSizes.s8,
  });

  final MuscleFocusEntry muscle;
  final TextStyle? nameStyle;
  final TextStyle? valueStyle;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlight = muscle.highlight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                muscle.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    nameStyle ??
                    AppTypography.bodyLargeSemiBoldTight.copyWith(
                      color: colors.textPrimary,
                    ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              muscle.shareLabel,
              style:
                  valueStyle ??
                  AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(
          progress: muscle.share,
          color: colors.primaryAlt,
          trackColor: colors.borderSubtle,
          height: barHeight,
        ),
        if (highlight != null) ...[
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.bolt, size: AppSizes.s14, color: colors.primaryAlt),
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  highlight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallMediumTight.copyWith(
                    color: colors.primaryAlt,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
