import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppSpinner extends StatefulWidget {
  const AppSpinner({
    super.key,
    this.size = AppSizes.s24,
    this.strokeWidth = AppSizes.s2,
    this.color,
    this.revealDelay = Duration.zero,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final Duration revealDelay;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.spinnerReveal,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _reveal,
    curve: AppMotion.spinnerRevealCurve,
  );
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    if (widget.revealDelay == Duration.zero) {
      _reveal.forward();
      return;
    }
    _delay = Timer(widget.revealDelay, () {
      if (mounted) _reveal.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _opacity,
        child: SizedBox.square(
          dimension: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: widget.strokeWidth,
            strokeCap: StrokeCap.round,
            color: widget.color ?? context.colors.primary,
          ),
        ),
      ),
    );
  }
}
