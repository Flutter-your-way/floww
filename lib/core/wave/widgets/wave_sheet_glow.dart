import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveSheetGlow extends StatelessWidget {
  const WaveSheetGlow({super.key});

  static const double _blurRadius = 120;
  static const double _widthFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, -AppSizes.s120),
            child: FractionallySizedBox(
              widthFactor: _widthFactor,
              child: Container(
                height: AppSizes.s96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.borderGlow,
                      blurRadius: _blurRadius,
                      spreadRadius: AppSizes.s24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
