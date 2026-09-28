import 'package:flutter/material.dart';

class AppShapes {
  AppShapes._();

  static RoundedSuperellipseBorder border({
    required BorderRadiusGeometry borderRadius,
    BorderSide side = BorderSide.none,
  }) => RoundedSuperellipseBorder(borderRadius: borderRadius, side: side);

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
