import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveOrbButton extends StatefulWidget {
  const WaveOrbButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<WaveOrbButton> createState() => _WaveOrbButtonState();
}

class _WaveOrbButtonState extends State<WaveOrbButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (value != _pressed) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.s52,
      width: AppSizes.s52,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(
                      alpha: AppOpacity.softGlow,
                    ),
                    blurRadius: AppSizes.s40,
                  ),
                  BoxShadow(
                    color: context.colors.primary.withValues(
                      alpha: AppOpacity.buttonGlowStrong,
                    ),
                    blurRadius: AppSizes.s20,
                  ),
                ],
              ),
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: AppSizes.s128,
                  maxHeight: AppSizes.s128,
                  child: SvgPicture.asset(
                    AppImages.waveIcon,
                    width: AppSizes.s128,
                    height: AppSizes.s128,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
