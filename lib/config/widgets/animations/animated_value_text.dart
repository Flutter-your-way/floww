import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class AnimatedValueText extends StatelessWidget {
  const AnimatedValueText({
    super.key,
    required this.value,
    this.style,
    this.textAlign,
    this.duration = AppMotion.expand,
    this.alignment = Alignment.centerLeft,
  });

  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.expandCurve,
      switchOutCurve: AppMotion.collapseCurve,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [...previousChildren, ?currentChild],
      ),
      child: Text(
        value,
        key: ValueKey(value),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
