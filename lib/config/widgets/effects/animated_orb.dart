import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/utils/effects/orb_shader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({
    super.key,
    required this.size,
    this.palette = AppOrbPalette.flow,
    this.speaking = false,
    this.playIntro = true,
    this.animate = true,
    this.showWave = false,
    this.speed = 1,
    this.controller,
  });

  final double size;
  final AppOrbPalette palette;
  final bool speaking;
  final bool playIntro;
  final bool animate;
  final bool showWave;
  final double speed;
  final OrbController? controller;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class OrbController {
  _AnimatedOrbState? _state;
  void tap() => _state?._tap();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final _OrbClock _clock = _OrbClock();
  ui.FragmentShader? _shader;
  Duration? _last;

  @override
  void initState() {
    super.initState();
    _shader = OrbShader.create();
    _clock.start(widget);
    widget.controller?._state = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant AnimatedOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller!._state = null;
      }
      widget.controller?._state = this;
    }
    _syncTicker();
  }

  bool get _shouldRun =>
      widget.animate && !MediaQuery.disableAnimationsOf(context);

  void _syncTicker() {
    if (_shouldRun) {
      if (!_ticker.isActive) {
        _last = null;
        _ticker.start();
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
      _clock.settle(widget);
    }
  }

  void _onTick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    if (last == null) return;
    final dt = math.min((elapsed - last).inMicroseconds / 1e6, 1 / 20);
    _clock.advance(dt * widget.speed, widget);
  }

  void _tap() => _clock.tap();

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller!._state = null;
    _ticker.dispose();
    _clock.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _OrbPainter(
          shader: _shader,
          clock: _clock,
          showWave: widget.showWave,
        ),
      ),
    );
  }
}

class _OrbClock extends ChangeNotifier {
  static const double introDone = 3.0;
  static const double wrap = 3600.0;
  static const double paletteEase = 5.0;

  double t = 0;
  double introT = 0;
  double speak = 0;
  double particlePhase = 0;
  double wavePhase = 0;
  double? tapAge;
  AppOrbPalette palette = AppOrbPalette.flow;

  void start(AnimatedOrb w) {
    palette = w.palette;
    introT = w.playIntro ? 0 : introDone;
    speak = w.speaking ? 1 : 0;
  }

  void settle(AnimatedOrb w) {
    palette = w.palette;
    introT = introDone;
    speak = w.speaking ? 1 : 0;
    tapAge = null;
    notifyListeners();
  }

  void tap() {
    tapAge = 0;
    notifyListeners();
  }

  void advance(double dt, AnimatedOrb w) {
    t = (t + dt) % wrap;

    introT = math.min(introT + dt, introDone);

    final target = w.speaking ? 1.0 : 0.0;
    speak += (target - speak).clamp(-dt / 0.4, dt / 0.4);

    if (tapAge != null) {
      tapAge = tapAge! + dt;
      if (tapAge! > 4) tapAge = null;
    }

    particlePhase += dt * (1 + 1.5 * speak);
    wavePhase += dt * (3 + 4 * speak);

    palette = AppOrbPalette.lerp(
      palette,
      w.palette,
      1 - math.exp(-dt * paletteEase),
    );
    notifyListeners();
  }

  double get tapBoost => tapAge == null ? 0 : math.exp(-tapAge! * 3);

  double get appear =>
      introT < 0.45 ? 0.001 : _eo(_prog(introT, 0.45, 1.5)) * 0.999 + 0.001;

  double get flash =>
      (introT > 1.05 ? math.exp(-(introT - 1.05) * 4) * 0.9 : 0.0) +
      tapBoost * 0.5;

  double get energy =>
      0.9 + 0.1 * math.sin(t * 1.3) + 0.25 * speak + 0.2 * tapBoost;

  double get particleVis => _prog(introT, 1.2, 2.2);
  double get waveDraw => _eio(_prog(introT, 1.15, 1.9));
}

double _prog(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);
double _eo(double p) => 1 - math.pow(1 - p, 3).toDouble();
double _eio(double p) =>
    p < .5 ? 4 * p * p * p : 1 - math.pow(-2 * p + 2, 3).toDouble() / 2;

class _Particle {
  const _Particle(this.a, this.r, this.sp, this.ph, this.s, this.depth);
  final double a, r, sp, ph, s, depth;
}

const _innerR = 118.0;
const _outerR = 238.0;
const _particleCount = 48;

final List<_Particle> _particles = () {
  var seed = 11;
  double rnd() {
    seed = (seed * 16807) % 2147483647;
    return (seed - 1) / 2147483646;
  }

  return List.generate(_particleCount, (_) {
    final a = rnd() * 2 * math.pi;
    final u = rnd();
    final r = math.sqrt(
      _innerR * _innerR + u * (_outerR * _outerR - _innerR * _innerR),
    );
    final kepler = math.pow(_innerR / r, 1.5).toDouble();
    final sp = (0.10 + rnd() * 0.08) * (0.55 + 0.45 * kepler);
    final ph = rnd() * 2 * math.pi;
    final depth = rnd();
    final s = 0.7 + depth * 1.6;
    return _Particle(a, r, sp, ph, s, depth);
  });
}();

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.shader,
    required this.clock,
    required this.showWave,
  }) : super(repaint: clock);

  final ui.FragmentShader? shader;
  final _OrbClock clock;
  final bool showWave;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 500;
    final c = size.center(Offset.zero);
    final pal = clock.palette;
    final t = clock.t;
    final sp = clock.speak;

    final spillA = (0.22 * clock.appear * clock.energy).clamp(0.0, 1.0);
    canvas.drawCircle(
      c,
      230 * k,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          230 * k,
          [pal.spill.withValues(alpha: spillA), pal.spill.withValues(alpha: 0)],
          const [20 / 230, 1.0],
        ),
    );

    final vis = clock.particleVis;
    if (vis > 0) {
      final paint = Paint();
      for (final p in _particles) {
        final ang = p.a + clock.particlePhase * p.sp;
        final x = math.cos(ang) * p.r;
        final y = math.sin(ang) * p.r * 0.8;
        final twinkle = 0.5 + 0.5 * math.sin(t * 2 + p.ph);
        final a =
            (0.18 + 0.30 * p.depth + 0.30 * twinkle) * vis * (0.75 + 0.35 * sp);
        paint.color = pal.particle.withValues(alpha: a.clamp(0.0, 1.0));
        canvas.drawCircle(c + Offset(x, y) * k, p.s * k, paint);
      }
    }

    final s = shader;
    if (s != null) {
      s
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, t)
        ..setFloat(3, clock.appear)
        ..setFloat(4, clock.energy)
        ..setFloat(5, sp)
        ..setFloat(6, clock.flash);
      var i = 7;
      for (final col in pal.shaderColors) {
        s
          ..setFloat(i++, col.r)
          ..setFloat(i++, col.g)
          ..setFloat(i++, col.b);
      }
      canvas.drawRect(Offset.zero & size, Paint()..shader = s);
    } else {
      final r = 0.52 / 3 * size.width * clock.appear;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            c + Offset(-0.3 * r, -0.35 * r),
            r * 1.4,
            [pal.hi, pal.mid, pal.dark],
          ),
      );
    }

    final draw = clock.waveDraw;
    if (showWave && draw > 0) {
      final path = Path();
      final idle = 0.9 + 0.12 * math.sin(t * 2.4);
      const n = 120, x0 = 54.0, x1 = 146.0;
      for (var i = 0; i <= n; i++) {
        final u = i / n;
        if (u > draw) break;
        final x = x0 + (x1 - x0) * u;
        final env = math.sin(math.pi * ((u - 0.02) / 0.96).clamp(0.0, 1.0));
        final voice =
            0.55 +
            0.9 *
                (math.sin(t * 6.3) * math.sin(t * 2.9 + u * 3) +
                        0.35 * math.sin(t * 11 + u * 7))
                    .abs();
        final amp = 11 * env * (idle * (1 - sp) + voice * sp);
        final y = 50 + amp * math.sin(u * math.pi * 2 * 2.5 - clock.wavePhase);
        final pt = c + Offset(x - 100, y - 50) * k;
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      Paint stroke() => Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 7.2 * k;
      canvas.drawPath(
        path,
        stroke()
          ..color = pal.waveGlow.withValues(alpha: 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * k),
      );
      canvas.drawPath(path, stroke()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.shader != shader || old.clock != clock || old.showWave != showWave;
}
