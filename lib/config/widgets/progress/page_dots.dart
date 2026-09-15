import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.onSelected,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.sm),
          _PageDot(
            isActive: i == activeIndex,
            onTap: onSelected == null ? null : () => onSelected!(i),
          ),
        ],
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, this.onTap});

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        height: AppSizes.s8,
        width: isActive ? AppSizes.s24 : AppSizes.s8,
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary
              : context.colors.borderMedium,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}
