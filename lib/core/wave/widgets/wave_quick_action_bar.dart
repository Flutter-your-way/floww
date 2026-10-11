import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/widgets/wave_bottom_fade.dart';

class WaveQuickActionBar extends StatefulWidget {
  const WaveQuickActionBar({
    super.key,
    required this.actions,
    required this.onSelected,
    this.visible = true,
  });

  final List<WaveQuickAction> actions;
  final ValueChanged<WaveQuickAction> onSelected;
  final bool visible;

  @override
  State<WaveQuickActionBar> createState() => _WaveQuickActionBarState();
}

class _WaveQuickActionBarState extends State<WaveQuickActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waveSuggestionsShow,
    reverseDuration: AppMotion.waveSuggestionsHide,
    value: widget.visible ? 1 : 0,
  );

  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.waveSuggestionsSize,
  );

  List<CurvedAnimation> _chips = const [];

  @override
  void initState() {
    super.initState();
    _chips = _chipAnimations(widget.actions.length);
  }

  @override
  void didUpdateWidget(covariant WaveQuickActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actions.length != widget.actions.length) {
      _disposeChips();
      _chips = _chipAnimations(widget.actions.length);
    }
    if (oldWidget.visible == widget.visible) return;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _disposeChips() {
    for (final chip in _chips) {
      chip.dispose();
    }
  }

  @override
  void dispose() {
    _disposeChips();
    _controller.dispose();
    super.dispose();
  }

  List<CurvedAnimation> _chipAnimations(int count) => [
    for (var index = 0; index < count; index++) _chipAnimation(index),
  ];

  CurvedAnimation _chipAnimation(int index) {
    final start = math.min(
      AppMotion.waveSuggestionsChipStart +
          index * AppMotion.waveSuggestionsStagger,
      1 - AppMotion.waveSuggestionsSpan,
    );
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        start + AppMotion.waveSuggestionsSpan,
        curve: AppMotion.waveSuggestionsChipCurve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions;

    return WaveBottomFade(
      opacity: _size,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_size),
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    if (index > 0) SizedBox(width: AppSpacing.md),
                    _QuickActionReveal(
                      animation: _chips[index],
                      child: _QuickActionChip(
                        action: actions[index],
                        onTap: () => widget.onSelected(actions[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionReveal extends StatelessWidget {
  const _QuickActionReveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotion.waveSuggestionsRise),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: AppMotion.waveSuggestionsScale,
            end: 1,
          ).animate(animation),
          child: child,
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action, required this.onTap});

  final WaveQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        height: AppSizes.s40,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: Color.alphaBlend(colors.tint, colors.backgroundPrimary),
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: colors.borderAccent, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: AppSizes.s16, color: colors.primary),
            SizedBox(width: AppSpacing.md),
            Text(
              action.label,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
