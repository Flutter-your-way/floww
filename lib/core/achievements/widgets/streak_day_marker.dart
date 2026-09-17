import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/achievements/models/streak_day_status.dart';

class StreakDayMarker extends StatelessWidget {
  const StreakDayMarker({
    super.key,
    required this.status,
    this.size = AppSizes.s28,
  });

  final StreakDayStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconSize = size / 2;

    return switch (status) {
      StreakDayStatus.completed => _MarkerDot(
        size: size,
        color: colors.primary,
        child: Icon(
          Icons.check_rounded,
          size: iconSize,
          color: colors.backgroundPrimary,
        ),
      ),
      StreakDayStatus.partial => _MarkerDot(
        size: size,
        color: Colors.transparent,
        borderColor: colors.primary,
      ),
      StreakDayStatus.missed => _MarkerDot(
        size: size,
        color: colors.destructive,
        child: Icon(
          Icons.close_rounded,
          size: iconSize,
          color: colors.textPrimary,
        ),
      ),
      StreakDayStatus.upcoming => _MarkerDot(
        size: size,
        color: colors.backgroundSurface,
      ),
    };
  }
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot({
    required this.size,
    required this.color,
    this.borderColor,
    this.child,
  });

  static const double _borderWidth = 2;

  final double size;
  final Color color;
  final Color? borderColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final borderColor = this.borderColor;

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: _borderWidth),
      ),
      child: child,
    );
  }
}
