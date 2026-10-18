import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class YogaRatingRow extends StatelessWidget {
  const YogaRatingRow({
    super.key,
    required this.statement,
    required this.scale,
    required this.selected,
    required this.onSelected,
  });

  final String statement;
  final List<int> scale;
  final int? selected;
  final ValueChanged<int> onSelected;

  static const double _midpoint = 0.5;

  Color _toneOf(BuildContext context, int index) {
    final colors = context.colors;
    final last = scale.length - 1;
    final position = last <= 0 ? 1.0 : index / last;
    return position <= _midpoint
        ? Color.lerp(
            colors.destructive,
            colors.warning,
            position / _midpoint,
          )!
        : Color.lerp(
            colors.warning,
            colors.success,
            (position - _midpoint) / _midpoint,
          )!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          statement,
          style: AppTypography.bodyMediumMedium.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (var i = 0; i < scale.length; i++) ...[
              if (i > 0) SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RatingTile(
                  value: scale[i],
                  tone: _toneOf(context, i),
                  isLit: selected != null && scale[i] <= selected!,
                  isSelected: scale[i] == selected,
                  onTap: () => onSelected(scale[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({
    required this.value,
    required this.tone,
    required this.isLit,
    required this.isSelected,
    required this.onTap,
  });

  final int value;
  final Color tone;
  final bool isLit;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        height: AppSizes.s44,
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: isLit
              ? tone.withValues(alpha: AppOpacity.tintFill)
              : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isLit ? tone : colors.borderSubtle,
            width: AppSizes.s1,
          ),
          shadows: isLit
              ? [
                  BoxShadow(
                    color: tone.withValues(
                      alpha: isSelected
                          ? AppOpacity.buttonGlowStrong
                          : AppOpacity.buttonGlow,
                    ),
                    blurRadius: isSelected ? AppSizes.s16 : AppSizes.s12,
                    spreadRadius: -AppSizes.s2,
                  ),
                ]
              : null,
        ),
        child: Text(
          '$value',
          style: AppTypography.bodyLargeSemiBold.copyWith(
            color: isLit ? tone : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
