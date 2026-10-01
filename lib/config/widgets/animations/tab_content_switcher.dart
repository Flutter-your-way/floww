import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class TabContentSwitcher extends StatelessWidget {
  const TabContentSwitcher({
    super.key,
    required this.reverse,
    required this.child,
    this.duration = AppMotion.tabSwitch,
  });

  final bool reverse;
  final Widget child;
  final Duration duration;

  static Widget _layoutBuilder(List<Widget> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TabEntry(
            key: entries[i].key,
            isActive: i == entries.length - 1,
            child: entries[i],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.tabSwitchSizeCurve,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: PageTransitionSwitcher(
        duration: duration,
        reverse: reverse,
        layoutBuilder: _layoutBuilder,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            _TabContentTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
        child: child,
      ),
    );
  }
}

class _TabEntry extends StatelessWidget {
  const _TabEntry({super.key, required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double? edge = isActive ? null : 0;
    return Positioned(
      top: edge,
      left: edge,
      right: edge,
      child: IgnorePointer(ignoring: !isActive, child: child),
    );
  }
}

class _TabContentTransition extends StatelessWidget {
  const _TabContentTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, child) {
        final enter = AppMotion.tabSwitchCurve.transform(animation.value);
        final exit = AppMotion.tabSwitchExitCurve.transform(
          secondaryAnimation.value,
        );
        final fadeIn = AppMotion.tabSwitchFadeIn.transform(animation.value);
        final fadeOut = AppMotion.tabSwitchFadeOut.transform(
          secondaryAnimation.value,
        );
        final travel = 1 - AppMotion.tabSwitchScale;

        return Opacity(
          opacity: (fadeIn * (1 - fadeOut)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              AppMotion.slideDistanceTab * ((1 - enter) - exit),
              0,
            ),
            child: Transform.scale(
              scale: AppMotion.tabSwitchScale + travel * (enter - exit),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
