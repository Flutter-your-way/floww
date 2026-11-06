import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/effects/glass_lens.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/navigation/views/main_tab_view.dart';

class IosGlassNavBar extends StatefulWidget {
  const IosGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.height,
    required this.onSelect,
    this.shadows,
  });

  final List<NavTabItem> items;
  final int selectedIndex;
  final double height;
  final ValueChanged<int> onSelect;
  final List<BoxShadow>? shadows;

  @override
  State<IosGlassNavBar> createState() => _IosGlassNavBarState();
}

class _IosGlassNavBarState extends State<IosGlassNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: AppGlass.scrubSlide,
    value: 1,
  );

  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: AppGlass.lensLiftIn,
    reverseDuration: AppGlass.lensLiftOut,
  );

  late double _from = widget.selectedIndex.toDouble();
  late double _to = _from;
  double? _finger;
  int? _hover;
  int? _committed;
  Offset _origin = Offset.zero;
  double _width = 0;

  int get _count => widget.items.length;

  double get _step => (_width - AppGlass.scrubPadding * 2) / _count;

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(IosGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) return;
    if (_committed == widget.selectedIndex) {
      _committed = null;
      return;
    }
    _committed = null;
    if (_finger != null) return;
    _from = _center;
    _to = widget.selectedIndex.toDouble();
    if (_reduce) {
      _slide.value = 1;
      return;
    }
    _slide.forward(from: 0);
    _pulse();
  }

  @override
  void dispose() {
    _slide.dispose();
    _lift.dispose();
    super.dispose();
  }

  void _pulse() {
    _measure();
    _lift.forward().then((_) {
      if (mounted && _finger == null) _lift.reverse();
    });
  }

  void _measure() {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      _origin = box.localToGlobal(Offset.zero);
    }
  }

  (double, double) get _edges {
    final t = _slide.value;
    final finger = _finger;
    if (finger != null) {
      final c = _from + (finger - _from) * Curves.easeOutCubic.transform(t);
      return (c, c);
    }
    final lead = _from + (_to - _from) * AppGlass.scrubLead.transform(t);
    final trail = _from + (_to - _from) * AppGlass.scrubTrail.transform(t);
    return _to >= _from ? (trail, lead) : (lead, trail);
  }

  double get _center {
    final (a, b) = _edges;
    return (a + b) / 2;
  }

  double _slotAt(double dx) {
    final raw = (dx - AppGlass.scrubPadding - _step / 2) / _step;
    final max = (_count - 1).toDouble();
    double band(double over) => AppGlass.scrubRubberBand * over / (1 + over);
    if (raw < 0) return -band(-raw);
    if (raw > max) return max + band(raw - max);
    return raw;
  }

  void _startDrag(DragStartDetails details) {
    _measure();
    setState(() {
      _from = _center;
      _finger = _slotAt(details.localPosition.dx);
      _hover = _finger!.round().clamp(0, _count - 1);
    });
    if (_reduce) {
      _slide.value = 1;
      _lift.value = 1;
    } else {
      _slide
        ..value = 0
        ..animateTo(1, duration: AppGlass.scrubGrab);
      _lift.forward();
    }
    HapticManager.selection();
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_finger == null) return;
    final finger = _slotAt(details.localPosition.dx);
    final hover = finger.round().clamp(0, _count - 1);
    if (hover != _hover) HapticManager.selection();
    setState(() {
      _finger = finger;
      _hover = hover;
    });
  }

  void _endDrag([double velocity = 0]) {
    final finger = _finger;
    if (finger == null) return;
    final target = (finger + (velocity / _step) * AppGlass.scrubFlickCarry)
        .round()
        .clamp(0, _count - 1);
    setState(() {
      _from = finger;
      _to = target.toDouble();
      _finger = null;
      _hover = null;
      if (target != widget.selectedIndex) _committed = target;
    });
    if (_reduce) {
      _slide.value = 1;
      _lift.value = 0;
    } else {
      _slide.forward(from: 0);
      _lift.reverse();
    }
    widget.onSelect(target);
  }

  Rect _pillRect() {
    final (left, right) = _edges;
    final top = (widget.height - AppGlass.scrubPillHeight) / 2;
    return Rect.fromLTWH(
      AppGlass.scrubPadding + left * _step,
      top,
      (right - left) * _step + _step,
      AppGlass.scrubPillHeight,
    );
  }

  Rect _lensRect() {
    final lift = Curves.easeOutBack.transform(_lift.value);
    final w = lerpDouble(_step, AppGlass.lensWidth, lift)!;
    final h = lerpDouble(AppGlass.scrubPillHeight, AppGlass.lensHeight, lift)!;
    final cx = AppGlass.scrubPadding + _center * _step + _step / 2;
    return Rect.fromLTWH(cx - w / 2, (widget.height - h) / 2, w, h);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return AnimatedBuilder(
          animation: Listenable.merge([_slide, _lift]),
          builder: (context, child) {
            final active = _hover ?? _committed ?? widget.selectedIndex;
            final lens = _lift.value > 0 ? _lensRect() : null;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: _width,
                  height: widget.height,
                  child: LiquidGlass(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    shadows: widget.shadows,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: _startDrag,
                      onHorizontalDragUpdate: _updateDrag,
                      onHorizontalDragEnd: (details) =>
                          _endDrag(details.velocity.pixelsPerSecond.dx),
                      onHorizontalDragCancel: _endDrag,
                      child: Stack(
                        children: [
                          Positioned.fromRect(
                            rect: _pillRect(),
                            child: Opacity(
                              opacity:
                                  (1 - _lift.value * AppGlass.scrubPillFade)
                                      .clamp(0.0, 1.0),
                              child: const _ScrubPill(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppGlass.scrubPadding,
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < _count; i++)
                                  Expanded(
                                    child: _ScrubTabButton(
                                      item: widget.items[i],
                                      active: i == active,
                                      hovered: i == _hover,
                                      onTap: () => widget.onSelect(i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (lens != null)
                  Positioned.fromRect(
                    rect: lens,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: _lift.value.clamp(0.0, 1.0),
                        child: GlassLens(globalRect: lens.shift(_origin)),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ScrubPill extends StatelessWidget {
  const _ScrubPill();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.full);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: context.gradients.glassIndicator,
        border: Border.all(
          color: context.colors.textPrimary.withValues(
            alpha: AppGlass.indicatorRimOpacity,
          ),
          width: AppSizes.s1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(
              alpha: AppGlass.indicatorGlowOpacity,
            ),
            blurRadius: AppGlass.indicatorGlowBlur,
          ),
        ],
      ),
      child: InnerGlow(
        color: context.colors.textPrimary.withValues(
          alpha: AppGlass.innerGlowOpacity,
        ),
        radius: AppGlass.scrubPillHeight / 2,
      ),
    );
  }
}

class _ScrubTabButton extends StatefulWidget {
  const _ScrubTabButton({
    required this.item,
    required this.active,
    required this.hovered,
    required this.onTap,
  });

  final NavTabItem item;
  final bool active;
  final bool hovered;
  final VoidCallback onTap;

  @override
  State<_ScrubTabButton> createState() => _ScrubTabButtonState();
}

class _ScrubTabButtonState extends State<_ScrubTabButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active
        ? context.colors.textPrimary
        : context.colors.textMuted;
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.item.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Center(
          child: AnimatedScale(
            scale: _pressed
                ? AppMotion.pressScale
                : widget.hovered
                ? AppGlass.scrubHoverScale
                : 1,
            duration: AppGlass.iconFade,
            curve: Curves.easeOutBack,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: AppGlass.iconFade,
              builder: (context, value, child) => SvgPicture.asset(
                widget.item.iconAsset,
                width: AppSizes.s20,
                height: AppSizes.s20,
                colorFilter: ColorFilter.mode(value ?? color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
