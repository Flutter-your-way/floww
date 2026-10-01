import 'dart:math' as math;

import 'package:floww/config/constants/app_motion.dart';
import 'package:flutter/material.dart';

mixin StaggeredRevealMixin<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  int get revealCount;

  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: AppMotion.staggerReveal,
  );

  late final List<Animation<double>> _presences = List.generate(revealCount, (
    index,
  ) {
    final start = index * AppMotion.staggerRevealStep;
    final end = math.min(start + AppMotion.staggerRevealSpan, 1.0);
    return CurvedAnimation(
      parent: _revealController,
      curve: Interval(start, end, curve: AppMotion.enter),
    );
  });

  Animation<double> presence(int index) => _presences[index];

  @override
  void initState() {
    super.initState();
    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }
}
