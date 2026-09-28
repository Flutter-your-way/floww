import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class HeaderBlurBand extends StatelessWidget {
  const HeaderBlurBand({super.key});

  static double heightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top +
      kToolbarHeight +
      context.sizes.topHeaderEdgeExtra;

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final layers = sizes.topBlurLayers;
    final sigma = sizes.topBlurSigma / math.sqrt(layers);
    final filter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

    return IgnorePointer(
      child: RepaintBoundary(
        child: BackdropGroup(
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
                    child: ClipRect(
                      child: BackdropFilter.grouped(
                        filter: filter,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
