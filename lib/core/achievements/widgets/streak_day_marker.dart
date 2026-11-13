import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/achievements/models/streak_day_status.dart';
import 'package:floww/config/widgets/painters/medal_painter.dart';

class StreakDayMarker extends StatelessWidget {
  const StreakDayMarker({
    super.key,
    required this.status,
    this.size = AppSizes.s28,
  });

  final StreakDayStatus status;
  final double size;

  static const double _solidIconRatio = 0.5;
  static const double _facedIconRatio = 0.4;
  static const double _faceScale = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;

    return switch (status) {
      StreakDayStatus.completed => _MarkerMedal(
        size: size,
        painter: MedalPainter(
          shape: MedalShape.hexagon,
          rimGradient: gradients.ramp,
        ),
        icon: Icons.local_fire_department_rounded,
        iconSize: size * _solidIconRatio,
        iconColor: colors.backgroundPrimary,
      ),
      StreakDayStatus.partial => _MarkerMedal(
        size: size,
        painter: MedalPainter(
          shape: MedalShape.hexagon,
          rimGradient: gradients.ramp,
          face: colors.backgroundSecondary,
          faceScale: _faceScale,
        ),
        icon: Icons.local_fire_department_outlined,
        iconSize: size * _facedIconRatio,
        iconColor: colors.primary,
      ),
      StreakDayStatus.missed => _MarkerMedal(
        size: size,
        painter: MedalPainter(
          shape: MedalShape.hexagon,
          rimColor: colors.destructive,
          face: colors.backgroundSecondary,
          faceScale: _faceScale,
        ),
        icon: Icons.close_rounded,
        iconSize: size * _facedIconRatio,
        iconColor: colors.destructiveBorder,
      ),
      StreakDayStatus.upcoming => _MarkerMedal(
        size: size,
        painter: MedalPainter(
          shape: MedalShape.hexagon,
          rimColor: colors.backgroundSurface,
        ),
      ),
    };
  }
}

class _MarkerMedal extends StatelessWidget {
  const _MarkerMedal({
    required this.size,
    required this.painter,
    this.icon,
    this.iconSize,
    this.iconColor,
  });

  final double size;
  final CustomPainter painter;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: painter,
        child: icon == null
            ? null
            : Center(
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
      ),
    );
  }
}
