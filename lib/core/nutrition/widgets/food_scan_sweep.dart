import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class FoodScanSweep extends StatefulWidget {
  const FoodScanSweep({super.key, required this.top, required this.bottom});

  final double top;
  final double bottom;

  @override
  State<FoodScanSweep> createState() => _FoodScanSweepState();
}

class _FoodScanSweepState extends State<FoodScanSweep>
    with SingleTickerProviderStateMixin {
  static const _sweepDuration = Duration(milliseconds: 1800);
  static const double _blurSigma = 12;
  static const double _lineThickness = AppSizes.s2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _sweepDuration,
  )..repeat(reverse: true);

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = context.colors.textSecondary;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, blur) {
        final lineY = lerpDouble(widget.top, widget.bottom, _progress.value)!;
        return Stack(
          children: [
            Positioned(
              top: lineY,
              left: 0,
              right: 0,
              bottom: 0,
              child: blur!,
            ),
            Positioned(
              top: lineY - _lineThickness / 2,
              left: 0,
              right: 0,
              height: _lineThickness,
              child: ColoredBox(color: lineColor),
            ),
          ],
        );
      },
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
