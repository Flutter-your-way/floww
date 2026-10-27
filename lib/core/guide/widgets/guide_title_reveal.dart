import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_spacing.dart';

class GuideTitleReveal extends StatefulWidget {
  const GuideTitleReveal({
    super.key,
    required this.text,
    this.style,
    this.start = true,
  });

  final String text;
  final TextStyle? style;
  final bool start;

  @override
  State<GuideTitleReveal> createState() => _GuideTitleRevealState();
}

class _GuideTitleRevealState extends State<GuideTitleReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.guideTitleReveal,
  );

  @override
  void initState() {
    super.initState();
    if (widget.start) _controller.forward();
  }

  @override
  void didUpdateWidget(GuideTitleReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.start && !oldWidget.start) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.text.split(' ');
    final span = AppMotion.guideTitleSpan;
    final stagger = words.length > 1 ? (1 - span) / (words.length - 1) : 0.0;

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < words.length; i++)
          _GuideTitleWord(
            word: words[i],
            style: widget.style,
            controller: _controller,
            interval: Interval(
              (i * stagger).clamp(0.0, 1.0),
              (i * stagger + span).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
      ],
    );
  }
}

class _GuideTitleWord extends StatelessWidget {
  const _GuideTitleWord({
    required this.word,
    required this.style,
    required this.controller,
    required this.interval,
  });

  final String word;
  final TextStyle? style;
  final AnimationController controller;
  final Interval interval;

  @override
  Widget build(BuildContext context) {
    final text = Text(word, style: style);

    return AnimatedBuilder(
      animation: controller,
      child: text,
      builder: (context, child) {
        final t = interval.transform(controller.value);
        if (t >= 1) return child!;
        final sigma = AppMotion.guideTitleBlur * (1 - t);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, AppMotion.guideTitleRise * (1 - t)),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
