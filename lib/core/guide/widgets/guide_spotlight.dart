import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

@immutable
class GuideHole {
  const GuideHole(this.rect, this.radius);

  factory GuideHole.collapsed(Offset center) =>
      GuideHole(center & Size.zero, 0);

  final Rect rect;
  final double radius;

  bool get isVisible => rect.shortestSide >= AppSizes.s4;

  RRect get rrect => RRect.fromRectAndRadius(rect, Radius.circular(radius));

  bool contains(Offset point) => isVisible && rrect.contains(point);

  static GuideHole lerp(GuideHole a, GuideHole b, double t) => GuideHole(
    Rect.lerp(a.rect, b.rect, t)!,
    lerpDouble(a.radius, b.radius, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is GuideHole && other.rect == rect && other.radius == radius;

  @override
  int get hashCode => Object.hash(rect, radius);
}

class GuideSpotlight extends StatelessWidget {
  const GuideSpotlight({
    super.key,
    required this.hole,
    required this.pulse,
    required this.burst,
  });

  static const double _blurSigma = AppSizes.s6;

  final GuideHole hole;
  final Animation<double> pulse;
  final Animation<double> burst;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TweenAnimationBuilder<GuideHole>(
      tween: _GuideHoleTween(begin: hole, end: hole),
      duration: AppMotion.guideSpotlight,
      curve: AppMotion.guideSpotlightCurve,
      builder: (context, current, child) => Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: _SpotlightClipper(current),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: ColoredBox(
                color: colors.backgroundPrimary.withValues(
                  alpha: AppOpacity.guideScrim,
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightRingPainter(
                hole: current,
                pulse: pulse,
                burst: burst,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHoleTween extends Tween<GuideHole> {
  _GuideHoleTween({super.begin, super.end});

  @override
  GuideHole lerp(double t) => GuideHole.lerp(begin!, end!, t);
}

class _SpotlightClipper extends CustomClipper<Path> {
  const _SpotlightClipper(this.hole);

  final GuideHole hole;

  @override
  Path getClip(Size size) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(hole.rrect);
  }

  @override
  bool shouldReclip(_SpotlightClipper oldClipper) => oldClipper.hole != hole;
}

class _SpotlightRingPainter extends CustomPainter {
  _SpotlightRingPainter({
    required this.hole,
    required this.pulse,
    required this.burst,
    required this.color,
  }) : super(repaint: Listenable.merge([pulse, burst]));

  static const double _ringWidth = AppSizes.s2;
  static const double _glowWidth = AppSizes.s4;
  static const double _glowBlur = AppSizes.s10;

  final GuideHole hole;
  final Animation<double> pulse;
  final Animation<double> burst;
  final Color color;

  void _paintBurst(Canvas canvas, RRect rrect) {
    final t = burst.value;
    if (t <= 0 || t >= 1) return;
    for (final lag in const [0.0, 0.18]) {
      final local = ((t - lag) / (1 - lag)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeOutCubic.transform(local);
      canvas.drawRRect(
        rrect.inflate(AppMotion.guideBurstSpread * eased),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth * (1 - eased) + AppSizes.hairline
          ..color = color.withValues(alpha: (1 - eased) * (1 - lag)),
      );
    }
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(
          alpha: AppOpacity.softGlow * (1 - Curves.easeOut.transform(t)),
        ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!hole.isVisible) return;
    final t = pulse.value;
    final rrect = hole.rrect;
    _paintBurst(canvas, rrect);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..color = color.withValues(alpha: AppOpacity.guideHalo)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
    );
    canvas.drawRRect(
      rrect.inflate(AppMotion.guidePulseSpread * t),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = color.withValues(alpha: AppOpacity.guideHalo * (1 - t)),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpotlightRingPainter oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.color != color;
}
