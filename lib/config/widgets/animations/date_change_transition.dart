import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';

class DateChangeTransition extends StatefulWidget {
  const DateChangeTransition({
    super.key,
    required this.value,
    required this.direction,
    required this.child,
    this.duration = AppMotion.medium,
    this.distance = AppMotion.slideDistance,
  });

  final Object value;
  final DateChangeDirection direction;
  final Widget child;
  final Duration duration;
  final double distance;

  @override
  State<DateChangeTransition> createState() => _DateChangeTransitionState();
}

class _DateChangeTransitionState extends State<DateChangeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  late final Animation<double> _slide = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.enter,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.fadeIn,
  );

  @override
  void didUpdateWidget(DateChangeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sign = widget.direction == DateChangeDirection.forward ? 1.0 : -1.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(sign * widget.distance * (1 - _slide.value), 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
