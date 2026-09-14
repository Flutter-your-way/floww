import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

class AppShapes {
  AppShapes._();

  static const double smoothness = 0.6;

  static SmoothRectangleBorder border({
    required BorderRadiusGeometry borderRadius,
    BorderSide side = BorderSide.none,
  }) => SmoothRectangleBorder(
    borderRadius: borderRadius,
    smoothness: smoothness,
    side: side,
  );

  static ShapeDecoration decoration({
    required BorderRadiusGeometry borderRadius,
    Color? color,
    Gradient? gradient,
    DecorationImage? image,
    BorderSide side = BorderSide.none,
    List<BoxShadow>? shadows,
  }) => ShapeDecoration(
    color: color,
    gradient: gradient,
    image: image,
    shadows: shadows,
    shape: border(borderRadius: borderRadius, side: side),
  );
}
