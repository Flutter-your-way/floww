import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class EdgeFadeMask extends StatelessWidget {
  const EdgeFadeMask({
    super.key,
    required this.child,
    this.topFadeEnd,
    this.bottomInset = 0,
    this.fadeBottom = false,
    this.topFadeLength,
  });

  final Widget child;
  final double? topFadeEnd;
  final double bottomInset;
  final bool fadeBottom;
  final double? topFadeLength;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        final height = bounds.height;
        final fadeEnd = topFadeEnd;
        final fadeLength = topFadeLength;
        final topExtent = height > 0 && fadeLength != null
            ? fadeLength / height
            : AppGradientTokens.topFadeExtent;
        final topEdge = height > 0 && fadeEnd != null
            ? (fadeEnd / height - topExtent).clamp(0.0, 1.0)
            : 0.0;
        final bottomEdge = height > 0
            ? (1 - bottomInset / height).clamp(0.0, 1.0)
            : 1.0;
        if (bottomEdge <= topEdge) {
          return AppGradientTokens.edgeFadeMask().createShader(bounds);
        }

        return AppGradientTokens.edgeFadeMask(
          topEdge: topEdge,
          bottomEdge: bottomEdge,
          fadeBottom: fadeBottom,
          topExtent: topExtent,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
