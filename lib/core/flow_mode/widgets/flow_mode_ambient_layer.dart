import 'dart:async';
import 'dart:math' as math;

import 'package:floww/config/theme/app_mode_intensity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlowModeAmbientLayer extends StatefulWidget {
  const FlowModeAmbientLayer({super.key});

  @override
  State<FlowModeAmbientLayer> createState() => _FlowModeAmbientLayerState();
}

class _FlowModeAmbientLayerState extends State<FlowModeAmbientLayer> {
  static const int _repaintsPerSecond = 15;
  static const Duration _tickInterval = Duration(
    microseconds: Duration.microsecondsPerSecond ~/ _repaintsPerSecond,
  );

  final ValueNotifier<double> _phase = ValueNotifier(0);
  final Stopwatch _clock = Stopwatch();
  late final AppLifecycleListener _lifecycle;
  ValueListenable<TickerModeData>? _tickerMode;
  Timer? _timer;
  Duration _period = AppModeIntensity.flow.ambientDriftPeriod;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: (_) => _syncMotion());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerMode = TickerMode.getValuesNotifier(context);
    if (tickerMode != _tickerMode) {
      _tickerMode?.removeListener(_syncMotion);
      _tickerMode = tickerMode..addListener(_syncMotion);
    }
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _syncMotion();
  }

  @override
  void dispose() {
    _tickerMode?.removeListener(_syncMotion);
    _lifecycle.dispose();
    _timer?.cancel();
    _phase.dispose();
    super.dispose();
  }

  bool get _shouldAnimate {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return !_reducedMotion &&
        (_tickerMode?.value.enabled ?? true) &&
        (lifecycle == null || lifecycle == AppLifecycleState.resumed);
  }

  void _syncMotion() {
    final shouldAnimate = _shouldAnimate;
    if (shouldAnimate == (_timer != null)) return;

    if (shouldAnimate) {
      _clock
        ..reset()
        ..start();
      _timer = Timer.periodic(_tickInterval, (_) => _advance());
    } else {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
    }
  }

  void _advance() {
    final elapsed = _clock.elapsedMicroseconds;
    _clock
      ..reset()
      ..start();
    final period = _period.inMicroseconds;
    if (period <= 0) return;
    _phase.value = (_phase.value + elapsed / period) % 1;
  }

  @override
  Widget build(BuildContext context) {
    final intensity = context.intensity;
    _period = intensity.ambientDriftPeriod;

    return IgnorePointer(
      child: RepaintBoundary(
        child: ValueListenableBuilder<double>(
          valueListenable: _phase,
          builder: (context, phase, _) => CustomPaint(
            size: Size.infinite,
            isComplex: true,
            painter: _AmbientPainter(
              phase: phase,
              primary: context.colors.primary,
              deep: context.colors.primaryDeep,
              opacity: intensity.ambientOpacity,
              radiusFactor: intensity.ambientRadiusFactor,
              glow: intensity.glowStrength,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.phase,
    required this.primary,
    required this.deep,
    required this.opacity,
    required this.radiusFactor,
    required this.glow,
  });

  static const double _driftX = 0.16;
  static const double _driftY = 0.1;
  static const double _topAnchor = 0.18;
  static const double _bottomAnchor = 0.86;

  final double phase;
  final Color primary;
  final Color deep;
  final double opacity;
  final double radiusFactor;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = phase * 2 * math.pi;
    final radius = size.shortestSide * radiusFactor;

    _paintBloom(
      canvas,
      Offset(
        size.width * (0.5 + math.cos(angle) * _driftX),
        size.height * (_topAnchor + math.sin(angle) * _driftY),
      ),
      radius,
      primary,
      opacity * glow,
    );

    _paintBloom(
      canvas,
      Offset(
        size.width * (0.5 - math.sin(angle) * _driftX),
        size.height * (_bottomAnchor - math.cos(angle) * _driftY),
      ),
      radius * 0.78,
      deep,
      opacity * glow * 0.7,
    );
  }

  void _paintBloom(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha.clamp(0.0, 1.0)),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.primary != primary ||
      oldDelegate.deep != deep ||
      oldDelegate.opacity != opacity ||
      oldDelegate.radiusFactor != radiusFactor ||
      oldDelegate.glow != glow;
}
