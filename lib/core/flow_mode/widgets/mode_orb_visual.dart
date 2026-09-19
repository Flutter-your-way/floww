import 'dart:math' as math;

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_mode_intensity.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';
import 'package:flutter/material.dart';

class ModeOrbVisual extends StatelessWidget {
  const ModeOrbVisual({
    super.key,
    required this.mode,
    required this.progress,
    required this.colors,
    required this.intensity,
    required this.reducedMotion,
  });

  static const double _orbSize = AppSizes.s160 * 1.75;
  static const double _haloSpread = 1.5;
  static const double _entryScale = 0.74;
  static const double _fadeRate = 3;

  final AppThemeMode mode;
  final double progress;
  final AppColorTokens colors;
  final AppModeIntensity intensity;
  final bool reducedMotion;

  double get _entry =>
      intensity.entranceCurve.transform(progress.clamp(0.0, 1.0));

  double get _fade =>
      Curves.easeOut.transform(math.min(1, progress * _fadeRate));

  @override
  Widget build(BuildContext context) {
    final scale = _entryScale + (1 - _entryScale) * _entry;

    return RepaintBoundary(
      child: Center(
        child: SizedBox.square(
          dimension: _orbSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Halo(
                scale: scale * _haloSpread,
                color: colors.primaryDeep,
                opacity: AppOpacity.softGlow * intensity.glowStrength * _fade,
              ),
              Opacity(
                opacity: _fade,
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedOrb(
                    size: _orbSize,
                    palette: AppOrbPalette.of(mode),
                    spin: reducedMotion ? 0 : intensity.orbSpin,
                    orbit: reducedMotion ? 0 : intensity.orbOrbit,
                    ringGlow: intensity.orbRingGlow,
                    animate: !reducedMotion,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.scale,
    required this.color,
    required this.opacity,
  });

  final double scale;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity.clamp(0.0, 1.0)),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
