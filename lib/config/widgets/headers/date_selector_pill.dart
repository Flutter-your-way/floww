import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_typography.dart';

class DateSelectorPill extends StatelessWidget {
  const DateSelectorPill({
    super.key,
    required this.label,
    this.direction = DateChangeDirection.forward,
    this.onPrevious,
    this.onNext,
    this.onTapDate,
  });

  final String label;
  final DateChangeDirection direction;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTapDate;

  @override
  Widget build(BuildContext context) {
    final contentColor = context.colors.backgroundSecondary;

    return Container(
      height: AppSizes.s36,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: context.colors.surfaceTranslucent,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillArrow(icon: Icons.arrow_back_ios_new_rounded, onTap: onPrevious),
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onTapDate,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: contentColor,
                  size: AppSizes.s16,
                ),
                SizedBox(width: AppSpacing.xs),
                DateChangeTransition(
                  value: label,
                  direction: direction,
                  duration: AppMotion.fast,
                  distance: AppMotion.slideDistanceSmall,
                  child: Text(
                    label,
                    style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                      color: contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          _PillArrow(icon: Icons.arrow_forward_ios_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _PillArrow extends StatelessWidget {
  const _PillArrow({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.backgroundSurface.withValues(
      alpha: AppOpacity.mutedIcon,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSizes.s24,
        height: AppSizes.s36,
        child: Icon(
          icon,
          size: AppSizes.s16,
          color: onTap == null
              ? color.withValues(alpha: AppOpacity.disabled)
              : color,
        ),
      ),
    );
  }
}
