import 'package:flutter/material.dart';

class StepRevealItem extends StatelessWidget {
  const StepRevealItem({
    super.key,
    required this.presence,
    required this.child,
  });

  final Animation<double> presence;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: presence,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(presence),
        child: child,
      ),
    );
  }
}
