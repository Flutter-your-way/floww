import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/effects/liquid_glass_shader.dart';

class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.borderRadius,
    required this.child,
    this.blurSigma = AppGlass.blurSigma,
    this.refraction = AppGlass.refraction,
    this.thickness = AppGlass.edgeThickness,
    this.dispersion = AppGlass.dispersion,
    this.glare = AppGlass.glare,
    this.brightness = AppGlass.brightness,
    this.fillOpacity = AppGlass.fillOpacity,
    this.shadows,
  });

  final BorderRadius borderRadius;
  final Widget child;
  final double blurSigma;
  final double refraction;
  final double thickness;
  final double dispersion;
  final double glare;
  final double brightness;
  final double fillOpacity;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final shape = AppShapes.border(borderRadius: borderRadius);

    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeBorderClipper(shape: shape),
              child: LayoutBuilder(
                builder: (context, constraints) => _GlassSurface(
                  size: constraints.biggest,
                  borderRadius: borderRadius,
                  blurSigma: blurSigma,
                  refraction: refraction,
                  thickness: thickness,
                  dispersion: dispersion,
                  glare: glare,
                  brightness: brightness,
                  fillOpacity: fillOpacity,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GlassRimPainter(
                  shape: shape,
                  gradient: context.gradients.glassRim,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlassSurface extends StatefulWidget {
  const _GlassSurface({
    required this.size,
    required this.borderRadius,
    required this.blurSigma,
    required this.refraction,
    required this.thickness,
    required this.dispersion,
    required this.glare,
    required this.brightness,
    required this.fillOpacity,
  });

  final Size size;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double refraction;
  final double thickness;
  final double dispersion;
  final double glare;
  final double brightness;
  final double fillOpacity;

  @override
  State<_GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<_GlassSurface> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _shader = LiquidGlassShader.create();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  ui.ImageFilter _buildFilter(double devicePixelRatio) {
    final blur = ui.ImageFilter.blur(
      sigmaX: widget.blurSigma,
      sigmaY: widget.blurSigma,
      tileMode: TileMode.decal,
    );

    final shader = _shader;
    if (shader == null || widget.size.isEmpty) return blur;

    final radius = widget.borderRadius.topLeft.x * devicePixelRatio;
    shader
      ..setFloat(0, widget.size.width * devicePixelRatio)
      ..setFloat(1, widget.size.height * devicePixelRatio)
      ..setFloat(2, radius)
      ..setFloat(3, widget.thickness * devicePixelRatio)
      ..setFloat(4, widget.refraction * devicePixelRatio)
      ..setFloat(5, widget.dispersion)
      ..setFloat(6, widget.glare)
      ..setFloat(7, widget.brightness);

    return ui.ImageFilter.compose(
      outer: ui.ImageFilter.shader(shader),
      inner: blur,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: _buildFilter(MediaQuery.devicePixelRatioOf(context)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.gradients.glassFill,
          color: context.colors.backgroundSurface.withValues(
            alpha: widget.fillOpacity,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({required this.shape, required this.gradient});

  final ShapeBorder shape;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final path = shape.getOuterPath(bounds);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppGlass.rimWidth
      ..shader = gradient.createShader(bounds);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.gradient != gradient;
}
