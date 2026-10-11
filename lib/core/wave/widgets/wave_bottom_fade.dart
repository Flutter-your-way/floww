import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveBottomFade extends StatelessWidget {
  const WaveBottomFade({super.key, required this.child, this.opacity});

  static const double rise = AppSizes.s24;

  final Widget child;
  final Animation<double>? opacity;

  @override
  Widget build(BuildContext context) {
    final fade = DecoratedBox(
      decoration: BoxDecoration(gradient: context.gradients.bottomFade),
    );
    final opacity = this.opacity;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: -rise,
          child: IgnorePointer(
            child: opacity == null
                ? fade
                : FadeTransition(opacity: opacity, child: fade),
          ),
        ),
        child,
      ],
    );
  }
}
