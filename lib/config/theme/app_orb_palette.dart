import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';

@immutable
class AppOrbPalette {
  const AppOrbPalette({
    required this.dark,
    required this.mid,
    required this.hot,
    required this.ring,
  });

  static const AppOrbPalette restore = AppOrbPalette(
    dark: Color(0xFF105299),
    mid: Color(0xFF40B8F2),
    hot: Color(0xFFD9F7FF),
    ring: Color(0xFF85DBFF),
  );

  static const AppOrbPalette flow = AppOrbPalette(
    dark: Color(0xFF335C05),
    mid: Color(0xFF9EE524),
    hot: Color(0xFFEDFFB8),
    ring: Color(0xFFB8F259),
  );

  static const AppOrbPalette steady = AppOrbPalette(
    dark: Color(0xFF662103),
    mid: Color(0xFFF57314),
    hot: Color(0xFFFFD999),
    ring: Color(0xFFFF9E42),
  );

  static AppOrbPalette of(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => flow,
    AppThemeMode.steady => steady,
    AppThemeMode.restore => restore,
  };

  final Color dark;
  final Color mid;
  final Color hot;
  final Color ring;

  static AppOrbPalette lerp(AppOrbPalette a, AppOrbPalette b, double t) =>
      AppOrbPalette(
        dark: Color.lerp(a.dark, b.dark, t)!,
        mid: Color.lerp(a.mid, b.mid, t)!,
        hot: Color.lerp(a.hot, b.hot, t)!,
        ring: Color.lerp(a.ring, b.ring, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is AppOrbPalette &&
      other.dark == dark &&
      other.mid == mid &&
      other.hot == hot &&
      other.ring == ring;

  @override
  int get hashCode => Object.hash(dark, mid, hot, ring);
}
