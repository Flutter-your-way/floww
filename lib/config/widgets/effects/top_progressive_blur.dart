import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

class TopProgressiveBlur extends StatelessWidget {
  const TopProgressiveBlur({super.key, required this.child});

  final Widget child;

  static double bandHeightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top +
      kToolbarHeight +
      context.sizes.topBlurBandExtra;

  static double blurEdgeOf(BuildContext context) =>
      bandHeightOf(context) - context.sizes.topBlurEdgeFade;

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final band = bandHeightOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        if (!height.isFinite || height <= 0) return child;

        final fadeStart = (1 - band / height).clamp(0.0, 1.0);
        final solidStart = (1 - (band - sizes.topBlurEdgeFade) / height).clamp(
          fadeStart,
          1.0,
        );
        final ramp = solidStart - fadeStart;

        return ProgressiveBlurWidget(
          sigma: sizes.topBlurSigma,
          blurTextureDimensions: sizes.topBlurTextureSize,
          linearGradientBlur: LinearGradientBlur(
            values: const [0, 0.08, 0.3, 0.65, 1, 1],
            stops: [
              fadeStart,
              fadeStart + ramp * 0.35,
              fadeStart + ramp * 0.6,
              fadeStart + ramp * 0.82,
              solidStart,
              1,
            ],
            start: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          child: child,
        );
      },
    );
  }
}
