import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.gradient,
    this.trackColor,
    this.height = AppSizes.s6,
    this.glowColor,
  });

  final double progress;
  final Color? color;
  final Gradient? gradient;
  final Color? trackColor;
  final double height;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.full);
    final gradient = this.gradient;
    final glowColor = this.glowColor;

    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      decoration: AppShapes.decoration(
        color: trackColor ?? context.colors.backgroundElevated,
        borderRadius: radius,
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: AppShapes.decoration(
            color: gradient == null ? color ?? context.colors.primary : null,
            gradient: gradient,
            borderRadius: radius,
            shadows: glowColor == null
                ? null
                : [
                    BoxShadow(
                      color: glowColor.withValues(
                        alpha: AppOpacity.buttonGlowStrong,
                      ),
                      blurRadius: AppSizes.s8,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
