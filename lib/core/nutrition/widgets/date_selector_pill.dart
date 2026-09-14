import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class DateSelectorPill extends StatelessWidget {
  const DateSelectorPill({
    super.key,
    required this.label,
    this.onPrevious,
    this.onNext,
    this.onTapDate,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTapDate;

  @override
  Widget build(BuildContext context) {
    final contentColor = context.colors.backgroundPrimary;

    return Container(
      height: AppSizes.s36,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillArrow(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onPrevious,
          ),
          GestureDetector(
            onTap: onTapDate,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: contentColor,
                    size: AppSizes.s20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    final color = context.colors.backgroundPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSizes.s32,
        height: AppSizes.s36,
        child: Icon(
          icon,
          size: AppSizes.s16,
          color: onTap == null ? color.withValues(alpha: 0.3) : color,
        ),
      ),
    );
  }
}
