import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class PremiumSegmentedTabs<T> extends StatefulWidget {
  const PremiumSegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.badgeOf,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelOf;
  final String? Function(T item)? badgeOf;
  final ValueChanged<T> onSelected;

  @override
  State<PremiumSegmentedTabs<T>> createState() =>
      _PremiumSegmentedTabsState<T>();
}

class _PremiumSegmentedTabsState<T> extends State<PremiumSegmentedTabs<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _alignmentX;
  late double _travel;

  double _alignmentFor(T item) {
    final count = widget.items.length;
    final index = widget.items.indexOf(item);
    if (count < 2 || index < 0) return 0;

    return -1 + 2 * index / (count - 1);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.segment);
    final target = _alignmentFor(widget.selected);
    _travel = 0;
    _alignmentX = AlwaysStoppedAnimation<double>(target);
  }

  @override
  void didUpdateWidget(covariant PremiumSegmentedTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;

    final begin = _alignmentX.value;
    final end = _alignmentFor(widget.selected);
    _travel = (end - begin).abs() / 2;
    _alignmentX = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.segmentCurve),
    );
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeOf = widget.badgeOf;
    final count = widget.items.length;
    final hasIndicator = count > 0 && widget.items.contains(widget.selected);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Stack(
        children: [
          if (hasIndicator)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse = math.sin(math.pi * _controller.value) * _travel;
                  final stretch = AppMotion.segmentStretch * pulse;

                  return Align(
                    alignment: Alignment(_alignmentX.value, 0),
                    child: FractionallySizedBox(
                      widthFactor: 1 / count,
                      heightFactor: 1,
                      child: Transform.scale(
                        scaleX: 1 + stretch,
                        scaleY: 1 - stretch * AppMotion.segmentSquash,
                        child: child,
                      ),
                    ),
                  );
                },
                child: const _SegmentIndicator(),
              ),
            ),
          Row(
            children: [
              for (final item in widget.items)
                Expanded(
                  child: _Segment(
                    label: widget.labelOf(item),
                    badge: badgeOf == null ? null : badgeOf(item),
                    isSelected: item == widget.selected,
                    onTap: () => widget.onSelected(item),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentIndicator extends StatelessWidget {
  const _SegmentIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: AppShapes.decoration(
        gradient: context.gradients.primaryButton,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.surfaceTranslucent, width: AppSizes.s1),
        shadows: [
          BoxShadow(
            color: colors.primary.withValues(alpha: AppOpacity.buttonGlow),
            offset: const Offset(0, AppSizes.s4),
            blurRadius: AppSizes.s12,
            spreadRadius: -AppSizes.s4,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = this.badge;
    final foreground = isSelected
        ? colors.backgroundPrimary
        : colors.textSecondary;

    return PressScale(
      onTap: onTap,
      child: Container(
        height: AppSizes.s52,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.segmentLabel,
                curve: AppMotion.segmentCurve,
                style: AppTypography.labelLargeSemiBold.copyWith(
                  color: foreground,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: AppSpacing.sm),
              AnimatedDefaultTextStyle(
                duration: AppMotion.segmentLabel,
                curve: AppMotion.segmentCurve,
                style: AppTypography.labelSmallMedium.copyWith(
                  color: foreground,
                ),
                child: Text(badge, maxLines: 1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
