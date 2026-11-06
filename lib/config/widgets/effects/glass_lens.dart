import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/effects/glass_lens_shader.dart';

class GlassLens extends StatelessWidget {
  const GlassLens({
    super.key,
    required this.globalRect,
    this.strength = AppGlass.lensStrength,
  });

  final Rect globalRect;
  final double strength;

  static const List<double> _brighten = [
    AppGlass.lensBrightness,
    0,
    0,
    0,
    0,
    0,
    AppGlass.lensBrightness,
    0,
    0,
    0,
    0,
    0,
    AppGlass.lensBrightness,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final radius = globalRect.shortestSide / 2;
    ui.ImageFilter filter = const ui.ColorFilter.matrix(_brighten);
    final lens = GlassLensShader.filter(
      rectPx: Rect.fromLTWH(
        globalRect.left * ratio,
        globalRect.top * ratio,
        globalRect.width * ratio,
        globalRect.height * ratio,
      ),
      radiusPx: radius * ratio,
      strength: strength,
    );
    if (lens != null) {
      filter = ui.ImageFilter.compose(outer: filter, inner: lens);
    }
    final shape = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: context.colors.backgroundPrimary.withValues(
              alpha: AppGlass.lensShadowOpacity,
            ),
            blurRadius: AppGlass.lensShadowBlur,
            offset: const Offset(0, AppGlass.lensShadowOffset),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: filter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: shape,
              gradient: context.gradients.glassLens,
              border: Border.all(
                color: context.colors.textPrimary.withValues(
                  alpha: AppGlass.lensRimOpacity,
                ),
                width: AppGlass.lensRimWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
