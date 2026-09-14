import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/core/nutrition/widgets/food_scan_frame.dart';
import 'package:floww/core/nutrition/widgets/food_scan_sweep.dart';

class FoodScanOverlay extends StatelessWidget {
  const FoodScanOverlay({super.key, required this.isScanning});

  static const double _frameInset = AppSizes.s36;
  static const double _frameAspectRatio = 0.87;
  static const double _frameVerticalFactor = 0.41;
  static const _sweepFadeDuration = Duration(milliseconds: 250);

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth - _frameInset * 2;
        final frameHeight = frameWidth / _frameAspectRatio;
        final frameTop =
            (constraints.maxHeight - frameHeight) * _frameVerticalFactor;

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: _sweepFadeDuration,
              child: isScanning
                  ? FoodScanSweep(top: frameTop, bottom: frameTop + frameHeight)
                  : const SizedBox.expand(),
            ),
            Positioned(
              top: frameTop,
              left: _frameInset,
              width: frameWidth,
              height: frameHeight,
              child: const FoodScanFrame(),
            ),
          ],
        );
      },
    );
  }
}
