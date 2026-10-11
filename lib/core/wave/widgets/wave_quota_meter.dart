import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class WaveQuotaMeter extends StatelessWidget {
  const WaveQuotaMeter({
    super.key,
    required this.remaining,
    required this.limit,
    required this.isLow,
    required this.onTap,
  });

  final int remaining;
  final int limit;
  final bool isLow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = remaining <= 0
        ? colors.destructive
        : isLow
        ? colors.warning
        : colors.primary;
    final share = limit <= 0 ? 0.0 : (remaining / limit).clamp(0.0, 1.0);

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        height: AppSizes.s28,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: AppShapes.decoration(
          color: accent.withValues(alpha: AppOpacity.tintFill),
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(
            color: accent.withValues(alpha: AppOpacity.tintBorder),
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: AppSizes.s14,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: share),
                duration: AppMotion.expandSoft,
                curve: AppMotion.expandCurve,
                builder: (context, value, child) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: AppSizes.s2,
                  strokeCap: StrokeCap.round,
                  color: accent,
                  backgroundColor: accent.withValues(
                    alpha: AppOpacity.tintBorder,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            ClipRect(
              child: AnimatedSwitcher(
                duration: AppMotion.expand,
                switchInCurve: AppMotion.pop,
                switchOutCurve: AppMotion.collapseCurve,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '$remaining',
                  key: ValueKey(remaining),
                  style: AppTypography.bodySmallSemiBold.copyWith(
                    color: accent,
                  ),
                ),
              ),
            ),
            Text(
              '/$limit',
              style: AppTypography.bodySmallSemiBold.copyWith(
                color: colors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
