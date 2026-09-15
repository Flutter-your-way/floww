import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';

class BottomActionScrim extends StatelessWidget {
  const BottomActionScrim({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;

    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: sizes.bottomScrimSigma,
              sigmaY: sizes.bottomScrimSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.gradients.actionScrim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
