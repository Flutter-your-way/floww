import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class AppCardSwap extends StatelessWidget {
  const AppCardSwap({super.key, required this.child});

  final Widget child;

  static Widget _layout(Widget? current, List<Widget> previous) => Stack(
    alignment: Alignment.topCenter,
    clipBehavior: Clip.none,
    children: [...previous, ?current],
  );

  static Widget _transition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.cardSwapCurve,
      reverseCurve: AppMotion.cardSwapOutCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotion.cardSwapRise),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: AppMotion.cardSwapScale,
            end: 1,
          ).animate(curved),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.cardSwap,
      curve: AppMotion.cardSwapCurve,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        duration: AppMotion.cardSwap,
        reverseDuration: AppMotion.cardSwapOut,
        layoutBuilder: _layout,
        transitionBuilder: _transition,
        child: child,
      ),
    );
  }
}
