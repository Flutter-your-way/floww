import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class SetProgressDots extends StatelessWidget {
  const SetProgressDots({super.key, required this.statuses});

  static const double _dotSize = AppSizes.s44;

  final List<ActiveSetStatus> statuses;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < statuses.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.lg),
          _SetDot(status: statuses[i]),
        ],
      ],
    );
  }
}

class _SetDot extends StatelessWidget {
  const _SetDot({required this.status});

  final ActiveSetStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return switch (status) {
      ActiveSetStatus.completed => Container(
        width: SetProgressDots._dotSize,
        height: SetProgressDots._dotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
        ),
        child: Icon(
          Icons.check_circle_outline,
          size: AppSizes.s24,
          color: colors.backgroundPrimary,
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
