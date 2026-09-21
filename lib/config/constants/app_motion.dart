import 'package:flutter/animation.dart';

import 'package:floww/config/constants/app_sizes.dart';

class AppMotion {
  AppMotion._();

  static const Duration press = Duration(milliseconds: 120);
  static const Duration expand = Duration(milliseconds: 280);
  static const Duration fast = Duration(milliseconds: 480);
  static const Duration medium = Duration(milliseconds: 720);
  static const Duration modeShift = Duration(milliseconds: 900);
  static const Duration notice = Duration(milliseconds: 4000);

  static const Curve enter = Curves.easeOutQuart;
  static const Curve expandCurve = Curves.easeOutCubic;
  static const Curve collapseCurve = Curves.easeInCubic;
  static const double pressScale = 0.98;
  static const Curve fadeIn = Interval(0, 0.6, curve: Curves.easeOut);

  static const double slideDistance = AppSizes.s32;
  static const double slideDistanceSmall = AppSizes.s12;
  static const double slideDistanceTab = AppSizes.s24;

  static const Duration segment = Duration(milliseconds: 460);
  static const Duration segmentLabel = Duration(milliseconds: 320);
  static const Curve segmentCurve = Cubic(0.2, 1, 0.3, 1);
  static const double segmentStretch = 0.14;
  static const double segmentSquash = 0.5;

  static const Duration tabSwitch = Duration(milliseconds: 420);
  static const Curve tabSwitchCurve = Curves.easeOutCubic;
  static const Curve tabSwitchExitCurve = Curves.easeInCubic;
  static const Curve tabSwitchSizeCurve = Curves.easeInOutCubic;
  static const Interval tabSwitchFadeIn = Interval(
    0.32,
    1,
    curve: Curves.easeOut,
  );
  static const Interval tabSwitchFadeOut = Interval(
    0,
    0.42,
    curve: Curves.easeIn,
  );
  static const double tabSwitchScale = 0.97;

  static const Duration modeTransitionReduced = Duration(milliseconds: 900);
  static const Duration modeSettleDebounce = Duration(milliseconds: 250);
  static const Duration modeSettleRetry = Duration(milliseconds: 200);
  static const Duration modeTransitionCooldown = Duration.zero;
  static const Duration modeTransitionWatchdog = Duration(seconds: 6);

  static const Curve modeImmerse = Curves.easeOutCubic;
  static const Curve modeRelease = Curves.easeInOutCubic;
  static const Curve modeBurst = Curves.easeOutExpo;

  static const Interval modeVeilIn = Interval(0, 0.12, curve: modeImmerse);
  static const Interval modeVeilOut = Interval(0.82, 1, curve: modeRelease);
  static const Interval modeContentOut = Interval(
    0.72,
    0.86,
    curve: Curves.easeIn,
  );
  static const Interval modeVisual = Interval(0.06, 0.74, curve: Curves.linear);
  static const Interval modeTitleIn = Interval(0.34, 0.6, curve: modeImmerse);
  static const Interval modeMessageIn = Interval(0.44, 0.7, curve: modeImmerse);
  static const double modeThemeSwitchPoint = 0.62;
  static const double modeVeilOpacity = 0.96;
  static const double modeVeilBlurSigma = AppSizes.s18;
  static const double modeCopyRise = AppSizes.s12;
  static const double modeCopyScale = 0.94;
  static const double modeReleaseScale = 1.06;
}
