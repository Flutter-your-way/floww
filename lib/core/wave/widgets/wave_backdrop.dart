import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveBackdrop extends StatelessWidget {
  const WaveBackdrop({super.key, this.blur = true});

  static const double _blurSigma = 12;

  final bool blur;

  @override
  Widget build(BuildContext context) {
    final scrim = ColoredBox(color: context.colors.scrim);
    if (!blur) return scrim;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
      child: scrim,
    );
  }
}
