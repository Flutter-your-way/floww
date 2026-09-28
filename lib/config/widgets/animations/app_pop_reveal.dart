import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class AppPopReveal extends StatefulWidget {
  const AppPopReveal({
    super.key,
    required this.child,
    this.duration = AppMotion.popReveal,
  });

  final Widget? child;
  final Duration duration;

  @override
  State<AppPopReveal> createState() => _AppPopRevealState();
}

class _AppPopRevealState extends State<AppPopReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.child == null ? 0 : 1,
  );

  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.popRevealSize,
  );

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.popRevealScaleIn,
    reverseCurve: AppMotion.popRevealScaleOut,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.popRevealFadeIn,
    reverseCurve: AppMotion.popRevealFadeOut,
  );

  late Widget? _child = widget.child;

  @override
  void didUpdateWidget(AppPopReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != null) {
      _child = widget.child;
      if (oldWidget.child == null) _controller.forward();
    } else if (oldWidget.child != null) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed || child == null) {
          return const SizedBox.shrink();
        }
        final scale =
            AppMotion.popRevealScale +
            (1 - AppMotion.popRevealScale) * _scale.value;
        final isEntering =
            _controller.status == AnimationStatus.forward ||
            _controller.isCompleted;
        return Align(
          alignment: Alignment.center,
          heightFactor: isEntering ? 1 : _size.value,
          child: Opacity(
            opacity: _fade.value.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: _child,
    );
  }
}
