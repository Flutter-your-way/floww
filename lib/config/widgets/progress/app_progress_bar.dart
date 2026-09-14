import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.trackColor,
    this.height = AppSizes.s6,
  });

  final double progress;
  final Color? color;
  final Color? trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.full);

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
            color: color ?? context.colors.primary,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}
