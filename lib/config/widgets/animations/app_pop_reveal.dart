import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class AppPopReveal extends StatefulWidget {
  const AppPopReveal({
    super.key,
    required this.child,
    this.duration = AppMotion.popReveal,
    this.trigger,
    this.appearOnMount = false,
  });

  final Widget? child;
  final Duration duration;
  final Object? trigger;
  final bool appearOnMount;

  @override
  State<AppPopReveal> createState() => _AppPopRevealState();
}

class _AppPopRevealState extends State<AppPopReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.child == null || widget.appearOnMount ? 0 : 1,
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
  void initState() {
    super.initState();
    if (widget.appearOnMount && widget.child != null) _controller.forward();
  }

  @override
  void didUpdateWidget(AppPopReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != null) {
      _child = widget.child;
      if (oldWidget.child == null) {
        _controller.forward();
      } else if (widget.trigger != oldWidget.trigger) {
        _controller.forward(from: 0);
      }
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
      child: _child == null ? null : AppPopRevealScope(child: _child!),
    );
  }
}

class AppPopRevealScope extends InheritedWidget {
  const AppPopRevealScope({super.key, required super.child});

  static bool isActive(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppPopRevealScope>() != null;

  @override
  bool updateShouldNotify(AppPopRevealScope oldWidget) => false;
}
