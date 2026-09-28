import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class SetProgressDots extends StatelessWidget {
  const SetProgressDots({super.key, required this.dots, this.onTapLogged});

  static const double _dotSize = AppSizes.s44;

  final List<ActiveSetDotItem> dots;
  final ValueChanged<int>? onTapLogged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final dot in dots)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: dot.loggedIndex == null || onTapLogged == null
                ? null
                : () => onTapLogged!(dot.loggedIndex!),
            child: _SetDot(dot: dot),
          ),
      ],
    );
  }
}

class _SetDot extends StatelessWidget {
  const _SetDot({required this.dot});

  final ActiveSetDotItem dot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return switch (dot.status) {
      ActiveSetStatus.completed => Container(
        width: SetProgressDots._dotSize,
        height: SetProgressDots._dotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dot.badge.isEmpty ? colors.primary : colors.bgTinted,
          border: dot.badge.isEmpty
              ? null
              : Border.all(color: colors.primary, width: AppSizes.s1),
        ),
        child: dot.badge.isEmpty
            ? Icon(
                Icons.check_circle_outline,
                size: AppSizes.s24,
                color: colors.backgroundPrimary,
              )
            : Text(
                dot.badge,
                style: AppTypography.labelMediumSemiBold.copyWith(
                  color: colors.primaryAlt,
                ),
              ),
      ),
      ActiveSetStatus.current => Container(
        width: SetProgressDots._dotSize,
        height: SetProgressDots._dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.bgTinted,
          border: Border.all(color: colors.primary, width: AppSizes.s2),
        ),
      ),
      ActiveSetStatus.pending => Container(
        width: SetProgressDots._dotSize,
        height: SetProgressDots._dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.backgroundSecondary,
          border: Border.all(color: colors.borderSubtle, width: AppSizes.s1),
        ),
      ),
    };
  }
}
