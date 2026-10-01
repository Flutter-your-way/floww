import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/typewriter_text.dart';

class ModeDetailReveal extends StatefulWidget {
  const ModeDetailReveal({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.color,
    this.onRevealed,
  });

  final String iconPath;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onRevealed;

  @override
  State<ModeDetailReveal> createState() => _ModeDetailRevealState();
}

class _ModeDetailRevealState extends State<ModeDetailReveal> {
  static const _typingSpeed = Duration(milliseconds: 30);
  static const _popDuration = Duration(milliseconds: 420);

  bool _iconVisible = false;
  bool _titleVisible = false;
  bool _titleTyped = false;
  Timer? _titleRevealTimer;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _iconVisible = true);
      _titleRevealTimer = Timer(_popDuration, () {
        if (mounted) setState(() => _titleVisible = true);
      });
    });
  }

  @override
  void dispose() {
    _titleRevealTimer?.cancel();
    super.dispose();
  }

  Widget _pop({required bool visible, required Widget child}) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.7,
      duration: _popDuration,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: _popDuration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.s32),
        _pop(
          visible: _iconVisible,
          child: SvgPicture.asset(
            widget.iconPath,
            width: AppSizes.s96,
            height: AppSizes.s96,
            colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: AppSizes.s32),
        _pop(
          visible: _titleVisible,
          child: TypewriterText(
            text: widget.title,
            textAlign: TextAlign.center,
            start: _titleVisible,
            speed: _typingSpeed,
            onFinished: () => setState(() => _titleTyped = true),
            style: context.textTheme.displayLarge?.copyWith(
              color: widget.color,
              fontSize: 56,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.15,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl3),
        _pop(
          visible: _titleTyped,
          child: TypewriterText(
            text: widget.description,
            textAlign: TextAlign.center,
            start: _titleTyped,
            speed: _typingSpeed,
            onFinished: widget.onRevealed,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 19,
              fontFamily: 'PlusJakartaSans',
              color: Colors.white70,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
