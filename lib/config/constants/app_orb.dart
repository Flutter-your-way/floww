import 'dart:ui';

class AppOrb {
  AppOrb._();

  static const String shaderAsset = 'shaders/orb.frag';

  static const Offset center = Offset(0.5185, 0.5);
  static const double coreRadius = 0.247;
  static const double textureAspect = 1296 / 1214;

  static const double spin = 0.55;
  static const double tilt = 0.18;
  static const double pulse = 1.0;
  static const double orbit = 1.0;
  static const double ringGlow = 0.85;
}
