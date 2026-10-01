import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_row.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_tone_color.dart';

class MissedWorkoutAdvice extends StatelessWidget {
  const MissedWorkoutAdvice({super.key, required this.missed});

  static const String lockedLabel = "WAVE's advice for this missed session";

  final MissedWorkoutItem missed;

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      capability: PremiumCapability.adaptiveEngine,
      placeholder: const SizedBox.shrink(),
      locked: const PremiumLockedRow(
        capability: PremiumCapability.adaptiveEngine,
        label: lockedLabel,
      ),
      child: _MissedWorkoutAdviceContent(missed: missed),
    );
  }
}

class _MissedWorkoutAdviceContent extends StatelessWidget {
  const _MissedWorkoutAdviceContent({required this.missed});

  final MissedWorkoutItem missed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColor = missed.adviceTone.resolve(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.graphic_eq_rounded, size: AppSizes.s18, color: toneColor),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  missed.adviceTitle,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: toneColor,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  missed.advice,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
