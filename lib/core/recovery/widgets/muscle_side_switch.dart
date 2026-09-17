import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';

class MuscleSideSwitch extends StatelessWidget {
  const MuscleSideSwitch({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MuscleBodySide selected;
  final ValueChanged<MuscleBodySide> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final side in MuscleBodySide.values)
            _SideSegment(
              side: side,
              isSelected: side == selected,
              onTap: () => onSelected(side),
            ),
        ],
      ),
    );
  }
}

class _SideSegment extends StatelessWidget {
  const _SideSegment({
    required this.side,
    required this.isSelected,
    required this.onTap,
  });

  final MuscleBodySide side;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        height: AppSizes.s40,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          side.label,
          style: isSelected
              ? AppTypography.bodyLargeBold.copyWith(
                  color: colors.backgroundPrimary,
                )
              : AppTypography.bodyLargeSemiBold.copyWith(
                  color: colors.textSecondary,
                ),
        ),
      ),
    );
  }
}
