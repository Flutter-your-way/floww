import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveVoiceOrb extends StatefulWidget {
  const WaveVoiceOrb({super.key, required this.level, required this.isActive});

  final double level;
  final bool isActive;

  @override
  State<WaveVoiceOrb> createState() => _WaveVoiceOrbState();
}

class _WaveVoiceOrbState extends State<WaveVoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: AppMotion.waveVoiceRipple,
  )..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energy = widget.isActive
        ? AppMotion.waveVoiceRippleIdle +
              (1 - AppMotion.waveVoiceRippleIdle) * widget.level
        : 0.0;

    return SizedBox.square(
      dimension: AppSizes.s160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var index = 0; index < AppMotion.waveVoiceRippleCount; index++)
            _WaveVoiceRipple(
              animation: _ripple,
              offset: index / AppMotion.waveVoiceRippleCount,
              energy: energy,
            ),
          AnimatedScale(
            scale: 1 + AppMotion.waveVoiceOrbBoost * widget.level,
            duration: AppMotion.waveVoiceLevel,
            curve: Curves.easeOut,
            child: SvgPicture.asset(
              AppImages.waveIcon,
              width: AppSizes.s96,
              height: AppSizes.s96,
              theme: SvgTheme(currentColor: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveVoiceRipple extends StatelessWidget {
  const _WaveVoiceRipple({
    required this.animation,
    required this.offset,
    required this.energy,
  });

  final Animation<double> animation;
  final double offset;
  final double energy;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final phase = (animation.value + offset) % 1;
        return Opacity(
          opacity: (1 - phase) * AppMotion.waveVoiceRippleOpacity * energy,
          child: Transform.scale(
            scale: 1 + phase * AppMotion.waveVoiceRippleSpread * energy,
            child: child,
          ),
        );
      },
      child: Container(
        width: AppSizes.s96,
        height: AppSizes.s96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: AppSizes.s2),
        ),
      ),
    );
  }
}
