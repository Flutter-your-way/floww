import 'dart:async';

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.gradient,
    this.trackColor,
    this.height = AppSizes.s6,
    this.glowColor,
    this.animated = false,
    this.animationDelay = Duration.zero,
  });

  final double progress;
  final Color? color;
  final Gradient? gradient;
  final Color? trackColor;
  final double height;
  final Color? glowColor;
  final bool animated;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return _AnimatedProgressBar(
        progress: progress.clamp(0.0, 1.0),
        delay: animationDelay,
        color: color,
        gradient: gradient,
        trackColor: trackColor,
        height: height,
        glowColor: glowColor,
      );
    }

    final radius = BorderRadius.circular(AppRadius.full);
    final fillGradient = gradient;
    final fillGlowColor = glowColor;

    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      decoration: AppShapes.decoration(
        color: trackColor ?? context.colors.backgroundElevated,
        borderRadius: radius,
      ),
      child: RepaintBoundary(
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: AppShapes.decoration(
              color: fillGradient == null
                  ? color ?? context.colors.primary
                  : null,
              gradient: fillGradient,
              borderRadius: radius,
              shadows: fillGlowColor == null
                  ? null
                  : [
                      BoxShadow(
                        color: fillGlowColor.withValues(
                          alpha: AppOpacity.buttonGlowStrong,
                        ),
                        blurRadius: AppSizes.s8,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({
    required this.progress,
    required this.delay,
    required this.height,
    this.color,
    this.gradient,
    this.trackColor,
    this.glowColor,
  });

  final double progress;
  final Duration delay;
  final double height;
  final Color? color;
  final Gradient? gradient;
  final Color? trackColor;
  final Color? glowColor;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.expandCurve,
  );
  late final Tween<double> _tween = Tween<double>(
    begin: 0,
    end: widget.progress,
  );
  late final Animation<double> _value = _tween.animate(_curve);
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _startTimer = Timer(widget.delay, _controller.forward);
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress == _tween.end) return;
    if (_startTimer?.isActive ?? false) {
      _tween.end = widget.progress;
      return;
    }
    _tween
      ..begin = _value.value
      ..end = widget.progress;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _value,
      builder: (context, child) => AppProgressBar(
        progress: _value.value,
        color: widget.color,
        gradient: widget.gradient,
        trackColor: widget.trackColor,
        height: widget.height,
        glowColor: widget.glowColor,
      ),
    );
  }
}
