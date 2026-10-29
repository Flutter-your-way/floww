import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';

class WaveOrbButton extends StatefulWidget {
  const WaveOrbButton({super.key, this.onTap});

  static const double size = AppSizes.s52;

  final VoidCallback? onTap;

  @override
  State<WaveOrbButton> createState() => _WaveOrbButtonState();
}

class _WaveOrbButtonState extends State<WaveOrbButton> {
  final OrbController _orb = OrbController();
  bool _pressed = false;

  void _setPressed(bool value) {
    if (value != _pressed) setState(() => _pressed = value);
  }

  void _handleTap() {
    _orb.tap();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open WAVE',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? AppMotion.pressScale : 1,
          duration: AppMotion.press,
          curve: Curves.easeOut,
          child: WaveAvatarBadge(
            size: WaveOrbButton.size,
            contained: true,
            controller: _orb,
          ),
        ),
      ),
    );
  }
}
