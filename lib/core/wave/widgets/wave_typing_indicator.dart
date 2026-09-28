import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveTypingIndicator extends StatefulWidget {
  const WaveTypingIndicator({super.key});

  static const int dotCount = 3;

  @override
  State<WaveTypingIndicator> createState() => _WaveTypingIndicatorState();
}

class _WaveTypingIndicatorState extends State<WaveTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveTyping,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(
            color: context.colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < WaveTypingIndicator.dotCount; index++)
              Padding(
                padding: EdgeInsets.only(
                  right: index == WaveTypingIndicator.dotCount - 1
                      ? 0
                      : AppSpacing.sm,
                ),
                child: _WaveTypingDot(
                  animation: _controller,
                  offset: index * AppMotion.waveTypingStagger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WaveTypingDot extends StatelessWidget {
  const _WaveTypingDot({required this.animation, required this.offset});

  final Animation<double> animation;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final phase = (animation.value + offset) % 1;
        final wave = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
        return Opacity(
          opacity:
              AppMotion.waveTypingMinOpacity +
              (1 - AppMotion.waveTypingMinOpacity) * wave,
          child: child,
        );
      },
      child: Container(
        width: AppSizes.s6,
        height: AppSizes.s6,
        decoration: BoxDecoration(
          color: context.colors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
