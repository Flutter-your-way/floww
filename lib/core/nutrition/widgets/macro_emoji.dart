import 'package:flutter/material.dart';

import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MacroEmoji extends StatelessWidget {
  const MacroEmoji({super.key, required this.macro, required this.size});

  final MacroNutrient macro;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      macro.emoji,
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, height: 1),
    );
  }
}
