import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';

@immutable
class AppModeIntensity extends ThemeExtension<AppModeIntensity> {
  const AppModeIntensity({
    required this.motionScale,
    required this.glowStrength,
    required this.ambientOpacity,
    required this.ambientDriftPeriod,
    required this.ambientRadiusFactor,
    required this.titleTracking,
    required this.entranceCurve,
    required this.transitionDuration,
    required this.orbSpin,
    required this.orbOrbit,
    required this.orbRingGlow,
  });

  static const AppModeIntensity restore = AppModeIntensity(
    motionScale: 1.42,
    glowStrength: 0.52,
    ambientOpacity: 0.09,
    ambientDriftPeriod: Duration(milliseconds: 15000),
    ambientRadiusFactor: 1.08,
    titleTracking: AppSizes.s8,
    entranceCurve: Curves.easeInOutCubic,
    transitionDuration: Duration(milliseconds: 2400),
    orbSpin: 0.34,
    orbOrbit: 0.68,
    orbRingGlow: 0.72,
  );

  static const AppModeIntensity steady = AppModeIntensity(
    motionScale: 1.0,
    glowStrength: 0.78,
    ambientOpacity: 0.12,
    ambientDriftPeriod: Duration(milliseconds: 10500),
    ambientRadiusFactor: 0.9,
    titleTracking: AppSizes.s6,
    entranceCurve: Curves.easeOutCubic,
    transitionDuration: Duration(milliseconds: 2150),
    orbSpin: 0.55,
    orbOrbit: 1.0,
    orbRingGlow: 0.88,
  );

  static const AppModeIntensity flow = AppModeIntensity(
    motionScale: 0.74,
    glowStrength: 1.0,
    ambientOpacity: 0.15,
    ambientDriftPeriod: Duration(milliseconds: 7200),
    ambientRadiusFactor: 0.76,
    titleTracking: AppSizes.s4,
    entranceCurve: Curves.easeOutExpo,
    transitionDuration: Duration(milliseconds: 2250),
    orbSpin: 0.92,
    orbOrbit: 1.65,
    orbRingGlow: 1.15,
  );

  static AppModeIntensity of(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => flow,
    AppThemeMode.steady => steady,
    AppThemeMode.restore => restore,
  };

  final double motionScale;
  final double glowStrength;
  final double ambientOpacity;
  final Duration ambientDriftPeriod;
  final double ambientRadiusFactor;
  final double titleTracking;
  final Curve entranceCurve;
  final Duration transitionDuration;
  final double orbSpin;
  final double orbOrbit;
  final double orbRingGlow;

  Duration scaled(Duration base) =>
      Duration(microseconds: (base.inMicroseconds * motionScale).round());

  @override
  AppModeIntensity copyWith({
    double? motionScale,
    double? glowStrength,
    double? ambientOpacity,
    Duration? ambientDriftPeriod,
    double? ambientRadiusFactor,
    double? titleTracking,
    Curve? entranceCurve,
    Duration? transitionDuration,
    double? orbSpin,
    double? orbOrbit,
    double? orbRingGlow,
  }) {
    return AppModeIntensity(
      motionScale: motionScale ?? this.motionScale,
      glowStrength: glowStrength ?? this.glowStrength,
      ambientOpacity: ambientOpacity ?? this.ambientOpacity,
      ambientDriftPeriod: ambientDriftPeriod ?? this.ambientDriftPeriod,
      ambientRadiusFactor: ambientRadiusFactor ?? this.ambientRadiusFactor,
      titleTracking: titleTracking ?? this.titleTracking,
      entranceCurve: entranceCurve ?? this.entranceCurve,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      orbSpin: orbSpin ?? this.orbSpin,
      orbOrbit: orbOrbit ?? this.orbOrbit,
      orbRingGlow: orbRingGlow ?? this.orbRingGlow,
    );
  }

  @override
  AppModeIntensity lerp(ThemeExtension<AppModeIntensity>? other, double t) {
    if (other is! AppModeIntensity) return this;

    return AppModeIntensity(
      motionScale: _lerpDouble(motionScale, other.motionScale, t),
      glowStrength: _lerpDouble(glowStrength, other.glowStrength, t),
      ambientOpacity: _lerpDouble(ambientOpacity, other.ambientOpacity, t),
      ambientDriftPeriod: _lerpDuration(
        ambientDriftPeriod,
        other.ambientDriftPeriod,
        t,
      ),
      ambientRadiusFactor: _lerpDouble(
        ambientRadiusFactor,
        other.ambientRadiusFactor,
        t,
      ),
      titleTracking: _lerpDouble(titleTracking, other.titleTracking, t),
      entranceCurve: t < 0.5 ? entranceCurve : other.entranceCurve,
      transitionDuration: _lerpDuration(
        transitionDuration,
        other.transitionDuration,
        t,
      ),
      orbSpin: _lerpDouble(orbSpin, other.orbSpin, t),
      orbOrbit: _lerpDouble(orbOrbit, other.orbOrbit, t),
      orbRingGlow: _lerpDouble(orbRingGlow, other.orbRingGlow, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  static Duration _lerpDuration(Duration a, Duration b, double t) => Duration(
    microseconds: _lerpDouble(
      a.inMicroseconds.toDouble(),
      b.inMicroseconds.toDouble(),
      t,
    ).round(),
  );
}
