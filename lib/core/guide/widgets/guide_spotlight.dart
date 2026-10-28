import 'package:flutter/material.dart';

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
    this.dim = AppOpacity.guideScrim,
  });

  final GuideHole hole;
  final double dim;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: _SpotlightClipper(hole),
          child: ColoredBox(
            color: context.colors.backgroundPrimary.withValues(alpha: dim),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _SpotlightGlowPainter(
              hole: hole,
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }
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

class _SpotlightGlowPainter extends CustomPainter {
  const _SpotlightGlowPainter({required this.hole, required this.color});

  static const double _glowWidth = AppSizes.s8;
  static const double _glowBlur = AppSizes.s16;
  static const double _haloWidth = AppSizes.s4;
  static const double _haloBlur = AppSizes.s4;
  static const double _edgeWidth = 1.5;

  final GuideHole hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!hole.isVisible) return;
    final rrect = hole.rrect;
    canvas.drawRRect(
      rrect,
      Paint()..color = color.withValues(alpha: AppOpacity.guideGlowTint),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..color = color.withValues(alpha: AppOpacity.guideGlow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, _glowBlur),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _haloWidth
        ..color = color.withValues(alpha: AppOpacity.guideGlow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _haloBlur),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _edgeWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpotlightGlowPainter oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.color != color;
}
