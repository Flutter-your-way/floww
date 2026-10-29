import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';

class WaveAvatarBadge extends StatelessWidget {
  const WaveAvatarBadge({
    super.key,
    this.size = AppSizes.s44,
    this.animate = true,
    this.speaking = false,
    this.contained = false,
    this.controller,
  });

  static const double _canvasScale = 2.9;
  static const double _containedSpeed = 1.6;

  final double size;
  final bool animate;
  final bool speaking;
  final bool contained;
  final OrbController? controller;

  @override
  Widget build(BuildContext context) {
    final mode = context.select<ThemeModeController, AppThemeMode>(
      (controller) => controller.mode,
    );
    final canvas = size * _canvasScale;
    final orb = SizedBox.square(
      dimension: size,
      child: OverflowBox(
        maxWidth: canvas,
        maxHeight: canvas,
        child: IgnorePointer(
          child: AnimatedOrb(
            size: canvas,
            palette: AppOrbPalette.of(mode),
            animate: animate,
            speaking: speaking,
            playIntro: !contained,
            speed: contained ? _containedSpeed : 1,
            controller: controller,
          ),
        ),
      ),
    );

    if (!contained) return orb;
    return _OrbHalo(
      size: size,
      animate: animate,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.backgroundPrimary,
        ),
        child: ClipOval(child: orb),
      ),
    );
  }
}

class _OrbHalo extends StatefulWidget {
  const _OrbHalo({
    required this.size,
    required this.animate,
    required this.child,
  });

  static const double _glowScale = 2.2;
  static const double _restScale = 0.88;

  final double size;
  final bool animate;
  final Widget child;

  @override
  State<_OrbHalo> createState() => _OrbHaloState();
}

class _OrbHaloState extends State<_OrbHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AppMotion.waveThinkingBreath,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _breath,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _OrbHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final run = widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (run && !_breath.isAnimating) {
      _breath.repeat(reverse: true);
    } else if (!run && _breath.isAnimating) {
      _breath.stop();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    final glow = widget.size * _OrbHalo._glowScale;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          OverflowBox(
            maxWidth: glow,
            maxHeight: glow,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _curve,
                builder: (context, child) {
                  final t = _curve.value;
                  final alpha =
                      AppOpacity.orbHaloMin +
                      (AppOpacity.orbHaloMax - AppOpacity.orbHaloMin) * t;
                  return Transform.scale(
                    scale: _OrbHalo._restScale + (1 - _OrbHalo._restScale) * t,
                    child: SizedBox.square(
                      dimension: glow,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withValues(alpha: alpha),
                              color.withValues(alpha: alpha * 0.35),
                              color.withValues(alpha: 0),
                            ],
                            stops: const [0.3, 0.55, 1],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
