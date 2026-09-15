import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class ActiveWorkoutProgressHeader extends StatelessWidget {
  const ActiveWorkoutProgressHeader({
    super.key,
    required this.progress,
    required this.exerciseLabel,
    required this.setLabel,
  });

  static const double _trackHeight = AppSizes.s6;

  final double progress;
  final String exerciseLabel;
  final String setLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Stack(
            children: [
              Container(height: _trackHeight, color: colors.backgroundElevated),
              LayoutBuilder(
                builder: (context, constraints) => AnimatedContainer(
                  duration: AppMotion.expand,
                  curve: AppMotion.expandCurve,
                  height: _trackHeight,
                  width: constraints.maxWidth * progress,
                  decoration: AppShapes.decoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exerciseLabel,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              setLabel,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
