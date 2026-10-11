import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveThinkingIndicator extends StatefulWidget {
  const WaveThinkingIndicator({super.key, required this.steps});

  final List<String> steps;

  @override
  State<WaveThinkingIndicator> createState() => _WaveThinkingIndicatorState();
}

class _WaveThinkingIndicatorState extends State<WaveThinkingIndicator> {
  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(AppMotion.waveThinkingStep, (_) => _advance());
  }

  @override
  void didUpdateWidget(covariant WaveThinkingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_step >= widget.steps.length) _step = widget.steps.length - 1;
  }

  void _advance() {
    if (_step >= widget.steps.length - 1) return;
    setState(() => _step++);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.steps.isEmpty ? '' : widget.steps[_step];

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _WaveBreathingOrb(),
          SizedBox(width: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.waveThinkingSwap,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.collapseCurve,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, AppMotion.waveThinkingRise),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _WaveShimmerText(key: ValueKey(label), text: label),
          ),
        ],
      ),
    );
  }
}

class _WaveBreathingOrb extends StatefulWidget {
  const _WaveBreathingOrb();

  @override
  State<_WaveBreathingOrb> createState() => _WaveBreathingOrbState();
}

class _WaveBreathingOrbState extends State<_WaveBreathingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveThinkingBreath,
  )..repeat(reverse: true);

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveThinkingBreathCurve,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity:
            AppMotion.waveThinkingBreathOpacity +
            (1 - AppMotion.waveThinkingBreathOpacity) * _curve.value,
        child: Transform.scale(
          scale:
              AppMotion.waveThinkingBreathScale +
              (1 - AppMotion.waveThinkingBreathScale) * _curve.value,
          child: child,
        ),
      ),
      child: SvgPicture.asset(
        AppImages.waveIcon,
        width: AppSizes.s24,
        height: AppSizes.s24,
        theme: SvgTheme(currentColor: context.colors.primary),
      ),
    );
  }
}

class _WaveShimmerText extends StatefulWidget {
  const _WaveShimmerText({super.key, required this.text});

  final String text;

  @override
  State<_WaveShimmerText> createState() => _WaveShimmerTextState();
}

class _WaveShimmerTextState extends State<_WaveShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveThinkingShimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = context.gradients.waveShimmer;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(
          bounds.shift(Offset(bounds.width * (_controller.value * 2 - 1), 0)),
        ),
        child: child,
      ),
      child: Text(
        widget.text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}
