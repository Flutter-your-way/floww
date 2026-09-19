import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/animated_value_text.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';

class GoalRingSummary extends StatelessWidget {
  const GoalRingSummary({
    super.key,
    required this.goalValue,
    required this.remainingValue,
    required this.shareLabel,
    required this.progress,
    required this.consumedValue,
    required this.consumedUnit,
  });

  final String goalValue;
  final String remainingValue;
  final String shareLabel;
  final double progress;
  final String consumedValue;
  final String consumedUnit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Stat(label: 'GOAL', value: goalValue),
                  ),
                  Expanded(
                    child: _Stat(label: 'REMAINING', value: remainingValue),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Divider(height: 1, thickness: 1, color: colors.borderSubtle),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    width: AppSizes.s8,
                    height: AppSizes.s8,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  AnimatedValueText(
                    value: shareLabel,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        AppProgressRing(
          progress: progress,
          glowColor: colors.textPrimary,
          endColor: colors.textPrimary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Consumed', style: captionStyle),
              AnimatedValueText(
                value: consumedValue,
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Text(consumedUnit, style: captionStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        AnimatedValueText(
          value: value,
          style: AppTypography.bodyXLargeBold.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
