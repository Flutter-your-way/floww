import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppPulsePlaceholder extends StatefulWidget {
  const AppPulsePlaceholder({super.key, this.child});

  final Widget? child;

  @override
  State<AppPulsePlaceholder> createState() => _AppPulsePlaceholderState();
}

class _AppPulsePlaceholderState extends State<AppPulsePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.placeholderPulse,
  )..repeat(reverse: true);

  late final Animation<double> _alpha =
      Tween<double>(
            begin: AppOpacity.placeholderPulseMin,
            end: AppOpacity.placeholderPulseMax,
          )
          .chain(CurveTween(curve: AppMotion.placeholderPulseCurve))
          .animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textPrimary;

    return AnimatedBuilder(
      animation: _alpha,
      builder: (context, child) => ColoredBox(
        color: color.withValues(alpha: _alpha.value),
        child: child,
      ),
      child: SizedBox.expand(child: Center(child: widget.child)),
    );
  }
}
