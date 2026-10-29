import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class WaveMessageEntrance extends StatefulWidget {
  const WaveMessageEntrance({
    super.key,
    required this.animate,
    required this.alignment,
    required this.child,
    this.onStarted,
  });

  final bool animate;
  final Alignment alignment;
  final Widget child;
  final VoidCallback? onStarted;

  @override
  State<WaveMessageEntrance> createState() => _WaveMessageEntranceState();
}

class _WaveMessageEntranceState extends State<WaveMessageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveEnter,
    value: widget.animate ? 0 : 1,
  );

  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveEnterSize,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveEnterFade,
  );

  late final Animation<double> _rise = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveEnterRise,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    widget.onStarted?.call();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _size,
      builder: (context, child) => ClipRect(
        clipBehavior: _controller.isCompleted ? Clip.none : Clip.hardEdge,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: math.max(_size.value, 0),
          child: child,
        ),
      ),
      child: FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _rise,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, AppMotion.slideDistanceSmall * (1 - _rise.value)),
            child: Transform.scale(
              scale:
                  AppMotion.waveEnterScale +
                  (1 - AppMotion.waveEnterScale) * _rise.value,
              alignment: widget.alignment,
              child: child,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
