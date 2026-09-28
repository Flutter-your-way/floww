import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class RollingText extends StatefulWidget {
  const RollingText({
    super.key,
    required this.text,
    this.style,
    this.duration = AppMotion.stepper,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> {
  int _direction = 1;

  static double? _numericOf(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));

  @override
  void didUpdateWidget(RollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = _numericOf(oldWidget.text);
    final next = _numericOf(widget.text);
    if (previous == null || next == null || previous == next) return;
    _direction = next > previous ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    final style = (widget.style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final characters = widget.text.characters.toList();

    return AnimatedSize(
      duration: widget.duration,
      curve: AppMotion.stepperCurve,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < characters.length; i++)
            _RollingCharacter(
              key: ValueKey(characters.length - i),
              character: characters[i],
              direction: _direction,
              duration: widget.duration,
              style: style,
            ),
        ],
      ),
    );
  }
}

class _RollingCharacter extends StatelessWidget {
  const _RollingCharacter({
    super.key,
    required this.character,
    required this.direction,
    required this.duration,
    required this.style,
  });

  final String character;
  final int direction;
  final Duration duration;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.stepperCurve,
        switchOutCurve: AppMotion.stepperExitCurve,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.center,
          children: [...previousChildren, ?currentChild],
        ),
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == ValueKey(character);
          final offset =
              (isIncoming ? direction : -direction) * AppMotion.stepperSlide;

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, offset),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: AppMotion.stepperScale,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: Text(character, key: ValueKey(character), style: style),
      ),
    );
  }
}
