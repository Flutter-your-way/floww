import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/providers/guide_controller.dart';
import 'package:floww/core/guide/widgets/guide_card.dart';
import 'package:floww/core/guide/widgets/guide_connector.dart';
import 'package:floww/core/guide/widgets/guide_spotlight.dart';
import 'package:floww/navigation/widgets/app_bottom_nav_bar.dart';

class GuideOverlay extends StatelessWidget {
  const GuideOverlay({super.key});

  void _next(GuideController guide, GuideViewState view) {
    if (view.isLast) {
      HapticManager.success();
    } else {
      HapticManager.selection();
    }
    guide.next();
  }

  void _back(GuideController guide) {
    HapticManager.selection();
    guide.back();
  }

  void _skip(GuideController guide) {
    HapticManager.light();
    guide.skip();
  }

  @override
  Widget build(BuildContext context) {
    final guide = context.watch<GuideController>();
    final isTransitioning = context.select<FlowModeController, bool>(
      (controller) => controller.isTransitioning,
    );
    final view = guide.view;
    final isVisible = view != null && !isTransitioning;

    return AnimatedSwitcher(
      duration: AppMotion.guideEnter,
      reverseDuration: AppMotion.guideExit,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: isVisible
          ? _GuideLayer(
              key: ValueKey(view.flow.section),
              view: view,
              locate: guide.targetEntry,
              onNext: () => _next(guide, view),
              onBack: () => _back(guide),
              onSkip: () => _skip(guide),
              onUnavailable: guide.passUnavailableStep,
            )
          : const SizedBox.shrink(),
    );
  }
}

enum _CardPlacement { dock, below, above }

class _GuideLayer extends StatefulWidget {
  const _GuideLayer({
    super.key,
    required this.view,
    required this.locate,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onUnavailable,
  });

  final GuideViewState view;
  final GuideTargetEntry? Function(GuideTargetId id) locate;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onUnavailable;

  @override
  State<_GuideLayer> createState() => _GuideLayerState();
}

class _GuideLayerState extends State<_GuideLayer>
    with TickerProviderStateMixin {
  static const double _cardGap = AppSpacing.xl4;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.guideEnter,
  );

  late final Animation<double> _enter = CurvedAnimation(
    parent: _entrance,
    curve: AppMotion.guideEnterCurve,
  );

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.guidePulse,
  )..repeat();

  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: AppMotion.guideBurst,
  );

  late final Ticker _tracker = createTicker((_) => _track());

  final GlobalKey _cardKey = GlobalKey();

  GuideHole _hole = GuideHole.collapsed(Offset.zero);
  GuideTargetEntry? _entry;
  Offset? _lastCenter;
  double _cardHeight = 0;
  bool _ready = false;
  bool _hasLanded = false;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    HapticManager.soft();
    _tracker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  @override
  void didUpdateWidget(_GuideLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.view.index != widget.view.index) _resolve();
  }

  @override
  void dispose() {
    _token++;
    _tracker.dispose();
    _entrance.dispose();
    _pulse.dispose();
    _burst.dispose();
    super.dispose();
  }

  bool _isCurrent(int token) => mounted && token == _token;

  Future<void> _resolve() async {
    final token = ++_token;
    final step = widget.view.step;
    final hadTarget = _entry != null;

    if (step.targets.isEmpty) {
      if (hadTarget) {
        setState(() => _ready = false);
        await Future<void>.delayed(AppMotion.guideCardShrink);
        if (!_isCurrent(token)) return;
        _entry = null;
        _track();
        await Future<void>.delayed(AppMotion.guideCardSettle);
      }
      if (!_isCurrent(token)) return;
      _land();
      return;
    }

    setState(() => _ready = false);
    final shrink = Future<void>.delayed(AppMotion.guideCardShrink);
    final entry = await _locate(step.targets, token);
    await shrink;
    if (!_isCurrent(token)) return;
    if (entry == null) {
      widget.onUnavailable();
      return;
    }

    if (entry.context.mounted) {
      await Scrollable.ensureVisible(
        entry.context,
        alignment: AppMotion.guideScrollAlignment,
        duration: AppMotion.guideScroll,
        curve: AppMotion.guideScrollCurve,
      );
    }
    if (!_isCurrent(token)) return;
    _entry = entry;
    _track();
    if (_hasLanded) await Future<void>.delayed(AppMotion.guideCardSettle);
    if (!_isCurrent(token)) return;
    _land();
  }

  void _land() {
    final isFirst = !_hasLanded;
    setState(() {
      _ready = true;
      _hasLanded = true;
    });
    if (isFirst) _entrance.forward();
    if (widget.view.step.targets.isNotEmpty) {
      _burst.forward(from: 0);
      if (!isFirst) HapticManager.soft();
    }
  }

  Future<GuideTargetEntry?> _locate(List<GuideTargetId> ids, int token) async {
    for (var i = 0; i < AppMotion.guideLocateAttempts; i++) {
      final primaryOnly = i < AppMotion.guideLocateAttempts ~/ 2;
      final found = _firstMounted(primaryOnly ? ids.take(1) : ids);
      if (found != null) return found;
      await Future<void>.delayed(AppMotion.guideLocatePoll);
      if (!_isCurrent(token)) return null;
    }
    return _scrollSearch(ids, token);
  }

  GuideTargetEntry? _firstMounted(Iterable<GuideTargetId> ids) {
    for (final id in ids) {
      final entry = widget.locate(id);
      if (entry != null) return entry;
    }
    return null;
  }

  ScrollPosition? _sectionScroll() {
    for (final step in widget.view.flow.steps) {
      for (final id in step.targets) {
        final entry = widget.locate(id);
        if (entry == null) continue;
        final position = Scrollable.maybeOf(entry.context)?.position;
        if (position != null) return position;
      }
    }
    return null;
  }

  Future<GuideTargetEntry?> _scrollSearch(
    List<GuideTargetId> ids,
    int token,
  ) async {
    final position = _sectionScroll();
    if (position == null) return null;
    var forward = widget.view.direction >= 0;
    var reversed = false;

    for (var i = 0; i < AppMotion.guideScrollAttempts; i++) {
      final stride = position.viewportDimension * AppMotion.guideScrollStep;
      final destination = forward
          ? math.min(position.pixels + stride, position.maxScrollExtent)
          : math.max(position.pixels - stride, position.minScrollExtent);
      if (destination == position.pixels) {
        if (reversed) return null;
        reversed = true;
        forward = !forward;
        continue;
      }
      await position.animateTo(
        destination,
        duration: AppMotion.guideScroll,
        curve: AppMotion.guideScrollCurve,
      );
      await WidgetsBinding.instance.endOfFrame;
      if (!_isCurrent(token)) return null;
      final found = _firstMounted(ids);
      if (found != null) return found;
    }
    return null;
  }

  void _track() {
    if (!mounted) return;
    final hole = _measure();
    final cardBox = _cardKey.currentContext?.findRenderObject();
    final cardHeight = cardBox is RenderBox && cardBox.hasSize
        ? cardBox.size.height
        : _cardHeight;
    if (hole == _hole && cardHeight == _cardHeight) return;
    setState(() {
      _hole = hole;
      _cardHeight = cardHeight;
    });
  }

  RenderBox? get _origin {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize && box.attached ? box : null;
  }

  Rect? _rectOf(BuildContext? target, RenderBox? origin) {
    final box = target?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    final global = box.localToGlobal(Offset.zero);
    final topLeft = origin == null ? global : origin.globalToLocal(global);
    return topLeft & box.size;
  }

  GuideHole _measure() {
    final origin = _origin;
    final hole = _targetHole(origin);
    if (hole != null) {
      _lastCenter = hole.rect.center;
      return hole;
    }
    final size = origin?.size ?? MediaQuery.sizeOf(context);
    return GuideHole.collapsed(
      _lastCenter ?? Offset(size.width / 2, size.height),
    );
  }

  GuideHole? _targetHole(RenderBox? origin) {
    final entry = _entry;
    if (entry == null || !entry.context.mounted) return null;
    final rect = _rectOf(entry.context, origin)?.inflate(entry.padding);
    if (rect == null) return null;
    final padding = MediaQuery.viewPaddingOf(context);
    final size = origin?.size ?? MediaQuery.sizeOf(context);
    final clipped = Rect.fromLTRB(
      math.max(rect.left, AppSpacing.xs),
      math.max(rect.top, padding.top),
      math.min(rect.right, size.width - AppSpacing.xs),
      math.min(
        rect.bottom,
        size.height -
            AppBottomNavBar.bottomInsetOf(context) -
            AppBottomNavBar.height,
      ),
    );
    if (clipped.height <= 0) return null;
    return GuideHole(clipped, entry.radius + entry.padding);
  }

  void _handleTap(TapUpDetails details) {
    if (!_ready || _entry == null) return;
    if (_hole.contains(details.localPosition)) widget.onNext();
  }

  _CardPlacement _placementFor(Size size, EdgeInsets padding) {
    if (_entry == null || !_hole.isVisible) return _CardPlacement.dock;
    final needed = _cardHeight + _cardGap;
    final navTop =
        size.height -
        AppBottomNavBar.bottomInsetOf(context) -
        AppBottomNavBar.height;
    final below = navTop - AppSpacing.xl - _hole.rect.bottom;
    final above = _hole.rect.top - padding.top - AppSpacing.xl;
    if (below >= needed) return _CardPlacement.below;
    if (above >= needed) return _CardPlacement.above;
    return _CardPlacement.dock;
  }

  double _cardTopFor(_CardPlacement placement, Size size, EdgeInsets padding) {
    final rect = _hole.rect;
    return switch (placement) {
      _CardPlacement.below => rect.bottom + _cardGap,
      _CardPlacement.above => rect.top - _cardGap - _cardHeight,
      _CardPlacement.dock =>
        size.height -
            AppBottomNavBar.bottomInsetOf(context) -
            AppBottomNavBar.height -
            AppSpacing.xl -
            _cardHeight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final placement = _placementFor(size, padding);
    final rect = _hole.rect;
    final horizontal = AppSpacing.xl;
    final connectorX = (rect.center.dx - GuideConnector.width / 2).clamp(
      horizontal + AppRadius.xl,
      size.width - horizontal - AppRadius.xl - GuideConnector.width,
    );

    final card = KeyedSubtree(
      key: _cardKey,
      child: GuideCard(
        view: widget.view,
        revealed: _ready,
        onNext: widget.onNext,
        onBack: widget.onBack,
        onSkip: widget.onSkip,
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleTap,
          child: GuideSpotlight(hole: _hole, pulse: _pulse, burst: _burst),
        ),
        TweenAnimationBuilder<double>(
          key: ValueKey(_hasLanded),
          tween: Tween(end: _cardTopFor(placement, size, padding)),
          duration: AppMotion.guideCardTravel,
          curve: AppMotion.guideCardTravelCurve,
          builder: (context, top, child) => Stack(
            fit: StackFit.expand,
            children: [
              if (placement == _CardPlacement.below)
                Positioned(
                  left: connectorX,
                  top: rect.bottom,
                  child: GuideConnector(
                    length: math.max(0, top - rect.bottom),
                    pointsUp: true,
                    visible: _ready,
                    flow: _pulse,
                  ),
                ),
              if (placement == _CardPlacement.above)
                Positioned(
                  left: connectorX,
                  top: top + _cardHeight,
                  child: GuideConnector(
                    length: math.max(0, rect.top - top - _cardHeight),
                    pointsUp: false,
                    visible: _ready,
                    flow: _pulse,
                  ),
                ),
              Positioned(
                left: horizontal,
                right: horizontal,
                top: top,
                child: child!,
              ),
            ],
          ),
          child: Opacity(
            opacity: _hasLanded ? 1 : 0,
            child: FadeTransition(
              opacity: _enter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, AppMotion.guideCardRise),
                  end: Offset.zero,
                ).animate(_enter),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: AppMotion.guideEnterScale,
                    end: 1,
                  ).animate(_enter),
                  child: _GuideTravelState(
                    moving: !_ready,
                    alignment: placement == _CardPlacement.below
                        ? Alignment.topCenter
                        : Alignment.bottomCenter,
                    child: card,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideTravelState extends StatelessWidget {
  const _GuideTravelState({
    required this.moving,
    required this.alignment,
    required this.child,
  });

  final bool moving;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: moving,
      child: AnimatedOpacity(
        opacity: moving ? AppOpacity.guideMoving : 1,
        duration: moving ? AppMotion.guideCardShrink : AppMotion.guideCardGrow,
        curve: moving
            ? AppMotion.guideCardShrinkCurve
            : AppMotion.guideCardGrowCurve,
        child: AnimatedScale(
          scale: moving ? AppMotion.guideMovingScale : 1,
          alignment: alignment,
          duration: moving
              ? AppMotion.guideCardShrink
              : AppMotion.guideCardGrow,
          curve: moving
              ? AppMotion.guideCardShrinkCurve
              : AppMotion.guideCardGrowCurve,
          child: child,
        ),
      ),
    );
  }
}
