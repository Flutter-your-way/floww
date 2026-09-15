import 'package:flutter/material.dart';

class LuminosityLayer extends StatelessWidget {
  const LuminosityLayer({super.key, required this.child, this.enabled = true});

  static const double _red = 0.2126;
  static const double _green = 0.7152;
  static const double _blue = 0.0722;

  static const List<double> _matrix = <double>[
    _red, _green, _blue, 0, 0, //
    _red, _green, _blue, 0, 0, //
    _red, _green, _blue, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_matrix),
      child: child,
    );
  }
}
