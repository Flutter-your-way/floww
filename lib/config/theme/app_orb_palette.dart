import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';

@immutable
class AppOrbPalette {
  const AppOrbPalette({
    required this.dark,
    required this.mid,
    required this.hi,
    required this.white,
    required this.sheen,
    required this.halo,
    required this.flash,
    required this.particle,
    required this.spill,
    required this.waveGlow,
  });

  static const AppOrbPalette flow = AppOrbPalette(
    dark: Color(0xFF0F1A05),
    mid: Color(0xFF61A814),
    hi: Color(0xFFB2F557),
    white: Color(0xFFEBFFBF),
    sheen: Color(0xFF809959),
    halo: Color(0xFF73C71F),
    flash: Color(0xFF99E64C),
    particle: Color(0xFFBEF56E),
    spill: Color(0xFF78BE1E),
    waveGlow: Color(0xFFDCFFA0),
  );

  static const AppOrbPalette steady = AppOrbPalette(
    dark: Color(0xFF1A1005),
    mid: Color(0xFFA86314),
    hi: Color(0xFFF5A157),
    white: Color(0xFFFFD7BF),
    sheen: Color(0xFF997659),
    halo: Color(0xFFC77B1F),
    flash: Color(0xFFE6A14C),
    particle: Color(0xFFF5AC6E),
    spill: Color(0xFFBE6C1E),
    waveGlow: Color(0xFFFFC8A0),
  );

  static const AppOrbPalette restore = AppOrbPalette(
    dark: Color(0xFF05151A),
    mid: Color(0xFF148BA8),
    hi: Color(0xFF57DFF5),
    white: Color(0xFFBFFDFF),
    sheen: Color(0xFF599299),
    halo: Color(0xFF1FA2C7),
    flash: Color(0xFF4CC4E6),
    particle: Color(0xFF6EE4F5),
    spill: Color(0xFF1EA5BE),
    waveGlow: Color(0xFFA0F7FF),
  );

  static AppOrbPalette of(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => flow,
    AppThemeMode.steady => steady,
    AppThemeMode.restore => restore,
  };

  final Color dark;
  final Color mid;
  final Color hi;
  final Color white;
  final Color sheen;
  final Color halo;
  final Color flash;
  final Color particle;
  final Color spill;
  final Color waveGlow;

  List<Color> get shaderColors => [dark, mid, hi, white, sheen, halo, flash];

  static AppOrbPalette lerp(AppOrbPalette a, AppOrbPalette b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppOrbPalette(
      dark: l(a.dark, b.dark),
      mid: l(a.mid, b.mid),
      hi: l(a.hi, b.hi),
      white: l(a.white, b.white),
      sheen: l(a.sheen, b.sheen),
      halo: l(a.halo, b.halo),
      flash: l(a.flash, b.flash),
      particle: l(a.particle, b.particle),
      spill: l(a.spill, b.spill),
      waveGlow: l(a.waveGlow, b.waveGlow),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppOrbPalette &&
      other.dark == dark &&
      other.mid == mid &&
      other.hi == hi &&
      other.white == white &&
      other.sheen == sheen &&
      other.halo == halo &&
      other.flash == flash &&
      other.particle == particle &&
      other.spill == spill &&
      other.waveGlow == waveGlow;

  @override
  int get hashCode => Object.hash(
    dark,
    mid,
    hi,
    white,
    sheen,
    halo,
    flash,
    particle,
    spill,
    waveGlow,
  );
}
