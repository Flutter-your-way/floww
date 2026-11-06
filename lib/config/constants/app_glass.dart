import 'package:flutter/animation.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';

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
  static const double buttonFillOpacity = 0.25;
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

  static const Duration indicatorPopIn = Duration(milliseconds: 520);
  static const Duration indicatorPopOut = Duration(milliseconds: 220);
  static const Curve indicatorPopCurve = Cubic(0.16, 1.5, 0.3, 1);
  static const Curve indicatorPopOutCurve = Curves.easeInCubic;
  static const Interval indicatorPopFade = Interval(
    0,
    0.36,
    curve: Curves.easeOut,
  );
  static const double indicatorPopScale = 0.52;
  static const double indicatorPopRise = AppSizes.s6;
  static const double indicatorPopSquash = 0.18;
  static const Duration indicatorPopSettle = Duration(milliseconds: 190);

  static const String lensShaderAsset = 'shaders/glass_lens.frag';
  static const double lensStrength = 0.32;
  static const double lensWidth = AppSizes.s80;
  static const double lensHeight = AppSizes.s72;
  static const double lensRimWidth = 1.6;
  static const double lensRimOpacity = 0.85;
  static const double lensBrightness = 1.06;
  static const double lensShadowOpacity = 0.35;
  static const double lensShadowBlur = AppSizes.s24;
  static const double lensShadowOffset = AppSizes.s10;

  static const Duration scrubSlide = Duration(milliseconds: 420);
  static const Duration scrubGrab = Duration(milliseconds: 200);
  static const Duration lensLiftIn = Duration(milliseconds: 240);
  static const Duration lensLiftOut = Duration(milliseconds: 360);
  static const Curve scrubEmphasized = Cubic(0.2, 0, 0, 1);
  static const Interval scrubLead = Interval(0, 0.75, curve: scrubEmphasized);
  static const Interval scrubTrail = Interval(0.12, 1, curve: scrubEmphasized);
  static const double scrubRubberBand = 0.35;
  static const double scrubFlickCarry = 0.08;
  static const double scrubHoverScale = 1.14;
  static const double scrubPillFade = 1.4;
  static const double scrubPadding = AppSizes.s8;
  static const double scrubPillHeight = AppSizes.s48;

  static const double iconLiftSelected = AppSizes.s2;
  static const double iconPopScale = 1.08;

  static const String tabLensShaderAsset = 'shaders/liquid_glass_lens.frag';
  static const String tabBackdropShaderAsset =
      'shaders/liquid_glass_backdrop.frag';
  static const double tabVeilOpacity = 0.094;
  static const double tabVeilPressedOpacity = 0.141;
  static const double tabBorderOpacity = 0.188;
  static const double tabBorderPressedOpacity = 0.29;
  static const double tabPillOpacity = 0.118;
  static const double tabGlassTintOpacity = 0.016;
  static const double tabRimStrength = 0.95;
  static const double tabIridescence = 0.85;
  static const double tabBarHeight = AppSizes.s60;
  static const double tabOrbSize = AppSizes.s48;
  static const double tabIconSize = 22;
  static const double tabSideInset = AppSpacing.lg;
  static const double tabLensOverhang = AppSizes.s6;
  static const double tabIconLabelGap = AppSizes.s2;
  static const double tabInset = 3.8;
  static const double tabPillExtraWidth = 7.3;
  static const double tabPressedZoom = 1.25;
  static const double tabRefraction = 1.0;
  static const double tabRefractionBlur = 0.33;
  static const double tabDispersion = 1.0;
  static const double tabLensGrowHeight = AppSizes.s4;
  static const double tabLensExtraWidth = 34;
  static const double tabBarSwell = 1.03;
  static const double tabFrost = 5.5;
  static const double tabSaturation = 1.25;
  static const double tabBarRefraction = 0.8;
  static const double tabTrailingExtent = AppSizes.s56;
  static const double tabDragGrowWidth = 0.12;
  static const double tabDragGrowHeight = AppSizes.s6;
}
