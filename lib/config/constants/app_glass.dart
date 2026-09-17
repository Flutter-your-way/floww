import 'package:floww/config/constants/app_sizes.dart';

class AppGlass {
  AppGlass._();

  static const String shaderAsset = 'shaders/liquid_glass.frag';

  static const double blurSigma = AppSizes.s16;
  static const double blurSigmaLight = AppSizes.s10;
  static const double refraction = AppSizes.s14;
  static const double refractionSoft = AppSizes.s8;
  static const double edgeThickness = AppSizes.s24;
  static const double edgeThicknessTight = AppSizes.s16;
  static const double dispersion = 0.35;
  static const double glare = 0.22;
  static const double brightness = 1.06;

  static const double fillOpacity = 0.1;
  static const double rimWidth = 1.2;
  static const double innerGlowOpacity = 0.22;
  static const double shadowOpacity = 0.45;
  static const double shadowBlur = AppSizes.s28;
  static const double shadowOffset = AppSizes.s8;

  static const double indicatorGlowOpacity = 0.3;
  static const double indicatorGlowBlur = AppSizes.s18;
  static const double indicatorRimOpacity = 0.4;
  static const double indicatorStretch = 0.16;
  static const double indicatorSquash = 0.55;
  static const double indicatorSize = AppSizes.s48;

  static const Duration indicatorTravel = Duration(milliseconds: 420);
  static const Duration iconFade = Duration(milliseconds: 240);
}
