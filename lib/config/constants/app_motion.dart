import 'package:flutter/animation.dart';

import 'package:floww/config/constants/app_sizes.dart';

class AppMotion {
  AppMotion._();

  static const Duration press = Duration(milliseconds: 120);
  static const Duration expand = Duration(milliseconds: 280);
  static const Duration fast = Duration(milliseconds: 480);
  static const Duration medium = Duration(milliseconds: 720);

  static const Curve enter = Curves.easeOutQuart;
  static const Curve expandCurve = Curves.easeOutCubic;
  static const Curve collapseCurve = Curves.easeInCubic;
  static const double pressScale = 0.98;
  static const Curve fadeIn = Interval(0, 0.6, curve: Curves.easeOut);

  static const double slideDistance = AppSizes.s32;
  static const double slideDistanceSmall = AppSizes.s12;
}
