import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class SetTracker extends StatelessWidget {
  const SetTracker({super.key, required this.sets, this.onTapLogged});

  final List<ActiveSetDotItem> sets;
  final ValueChanged<int>? onTapLogged;

  @override
  Widget build(BuildContext context) {
    final onTapLogged = this.onTapLogged;

    return Row(
      children: [
        for (var i = 0; i < sets.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: sets[i].loggedIndex == null || onTapLogged == null
                  ? null
                  : () => onTapLogged(sets[i].loggedIndex!),
              child: _SetChip(item: sets[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _SetChip extends StatelessWidget {
  const _SetChip({required this.item});

  static const double _height = AppSizes.s44;

  final ActiveSetDotItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = item.status == ActiveSetStatus.completed;
    final isCurrent = item.status == ActiveSetStatus.current;
    final hasBadge = item.badge.isNotEmpty;

    final background = switch (item.status) {
      ActiveSetStatus.completed => hasBadge ? colors.bgTinted : colors.primary,
      ActiveSetStatus.current => colors.bgTinted,
      ActiveSetStatus.pending => colors.backgroundSecondary,
    };
    final border = switch (item.status) {
      ActiveSetStatus.completed =>
        hasBadge ? Border.all(color: colors.primary, width: AppSizes.s1) : null,
      ActiveSetStatus.current => Border.all(
        color: colors.primary,
        width: AppSizes.s2,
      ),
      ActiveSetStatus.pending => Border.all(
        color: colors.borderSubtle,
        width: AppSizes.s1,
      ),
    };

    return AnimatedContainer(
      duration: AppMotion.expandSoft,
      curve: AppMotion.expandCurve,
      height: _height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: isCompleted && !hasBadge
          ? Icon(
              Icons.check_rounded,
              size: AppSizes.s20,
              color: colors.backgroundPrimary,
            )
          : Text(
              hasBadge ? item.badge : item.label,
              style: AppTypography.labelMediumSemiBold.copyWith(
                color: isCompleted || isCurrent
                    ? colors.primaryAlt
                    : colors.textSecondary,
              ),
            ),
    );
  }
}
