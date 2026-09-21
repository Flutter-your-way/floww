import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class TopProgressiveBlur extends StatelessWidget {
  const TopProgressiveBlur({super.key, required this.child});

  final Widget child;

  static double bandHeightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top +
      kToolbarHeight +
      context.sizes.topBlurBandExtra;

  static double blurEdgeOf(BuildContext context) => bandHeightOf(context);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: bandHeightOf(context),
          child: const _TopBlurBand(),
        ),
      ],
    );
  }
}

class _TopBlurBand extends StatelessWidget {
  const _TopBlurBand();

  @override
  Widget build(BuildContext context) {
    final layers = context.sizes.topBlurLayers;
    final sigma = context.sizes.topBlurSigma / math.sqrt(layers);

    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < layers; index++)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: constraints.maxHeight * (layers - index) / layers,
                  child: _BlurLayer(sigma: sigma),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurLayer extends StatelessWidget {
  const _BlurLayer({required this.sigma});

  final double sigma;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: const SizedBox.expand(),
      ),
    );
  }
}
