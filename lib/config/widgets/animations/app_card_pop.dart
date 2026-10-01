import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';

class AppCardPop extends StatelessWidget {
  const AppCardPop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppPopRevealScope.isActive(context)) return child;
    return _AppCardPopAnimation(child: child);
  }
}

class _AppCardPopAnimation extends StatefulWidget {
  const _AppCardPopAnimation({required this.child});

  final Widget child;

  @override
  State<_AppCardPopAnimation> createState() => _AppCardPopAnimationState();
}

class _AppCardPopAnimationState extends State<_AppCardPopAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.popReveal,
  )..forward();

  late final Animation<double> _scale =
      Tween<double>(begin: AppMotion.popRevealScale, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.popRevealScaleIn),
      );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.popRevealFadeIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: AppPopRevealScope(child: widget.child),
      ),
    );
  }
}
