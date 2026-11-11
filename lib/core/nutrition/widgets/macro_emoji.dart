import 'package:flutter/material.dart';

class MacroEmoji extends StatelessWidget {
  const MacroEmoji({super.key, required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, height: 1),
    );
  }
}
