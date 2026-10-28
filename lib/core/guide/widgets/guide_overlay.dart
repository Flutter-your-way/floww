import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/providers/guide_controller.dart';
import 'package:floww/core/guide/widgets/guide_card.dart';
import 'package:floww/core/guide/widgets/guide_spotlight.dart';
import 'package:floww/core/guide/widgets/guide_welcome.dart';
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
              onSkip: () => _skip(guide),
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
    required this.onSkip,
  });

  final GuideViewState view;
  final GuideTargetEntry? Function(GuideTargetId id) locate;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_GuideLayer> createState() => _GuideLayerState();
}

class _GuideLayerState extends State<_GuideLayer>
    with TickerProviderStateMixin {
  static const double _cardGap = AppSpacing.sm + GuideCard.caretHeight;
  static const double _cardWidthFactor = 0.82;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.guideEnter,
  );

  late final Animation<double> _enter = CurvedAnimation(
    parent: _entrance,
    curve: AppMotion.guideEnterCurve,
  );

  late final Ticker _tracker = createTicker(_track);

  final GlobalKey _cardKey = GlobalKey();

  final List<_Spring> _holeSprings = List.generate(5, (_) => _Spring());
  final _Spring _cardX = _Spring();
  final _Spring _cardY = _Spring();

  GuideHole _hole = GuideHole.collapsed(Offset.zero);
  _CardPlacement _placement = _CardPlacement.dock;
  GuideTargetEntry? _entry;
  Offset? _lastCenter;
  Duration _lastTick = Duration.zero;
  ScrollPosition? _scroll;
  double? _scrollTo;
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
        await Future<void>.delayed(AppMotion.guideCardSettle);
      }
      if (!_isCurrent(token)) return;
      _land();
      return;
    }

    final stay = _stayOn(step.targets);
    if (stay != null) {
      _entry = stay;
      if (!_ready) _land();
      return;
    }

    setState(() => _ready = false);
    final shrink = Future<void>.delayed(AppMotion.guideCardShrink);
    final entry = await _locate(step.targets, token);
    if (!_isCurrent(token)) return;
    if (entry == null) {
      _entry = null;
      if (_hasLanded) await Future<void>.delayed(AppMotion.guideCardSettle);
      if (!_isCurrent(token)) return;
      _land();
      return;
    }

    final reveal = _revealFor(entry);
    _scroll = reveal?.position;
    _scrollTo = reveal?.offset;
    _entry = entry;
    await Future.wait([
      shrink,
      if (reveal != null)
        reveal.position.animateTo(
          reveal.offset,
          duration: AppMotion.guideScroll,
          curve: AppMotion.guideScrollCurve,
        ),
    ]);
    if (!_isCurrent(token)) return;
    _scroll = null;
    _scrollTo = null;
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
    if (!isFirst && widget.view.step.targets.isNotEmpty) HapticManager.soft();
  }

  Future<GuideTargetEntry?> _locate(List<GuideTargetId> ids, int token) async {
    for (var i = 0; i < AppMotion.guideLocateAttempts; i++) {
      final primaryOnly = i < AppMotion.guideLocateAttempts ~/ 2;
      final found = _firstMounted(primaryOnly ? ids.take(1) : ids);
      if (found != null) return found;
      if (!primaryOnly && _onlyEmpty(ids)) return null;
      await Future<void>.delayed(AppMotion.guideLocatePoll);
      if (!_isCurrent(token)) return null;
    }
    return _scrollSearch(ids, token);
  }

  ({ScrollPosition position, double offset})? _revealFor(
    GuideTargetEntry entry,
  ) {
    if (!entry.context.mounted) return null;
    final object = entry.context.findRenderObject();
    final position = Scrollable.maybeOf(entry.context)?.position;
    if (object == null || position == null) return null;
    final viewport = RenderAbstractViewport.maybeOf(object);
    if (viewport == null) return null;
    final offset = viewport
        .getOffsetToReveal(object, AppMotion.guideScrollAlignment)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (offset == position.pixels) return null;
    return (position: position, offset: offset);
  }

  GuideTargetEntry? _stayOn(List<GuideTargetId> ids) {
    final current = _entry;
    if (current == null || !current.context.mounted) return null;
    final found = _firstMounted(ids);
    return found?.context == current.context ? found : null;
  }

  GuideTargetEntry? _firstMounted(Iterable<GuideTargetId> ids) {
    for (final id in ids) {
      final entry = widget.locate(id);
      if (entry != null && !_isEmpty(entry)) return entry;
    }
    return null;
  }

  bool _isEmpty(GuideTargetEntry entry) {
    final box = entry.context.findRenderObject();
    return box is RenderBox && box.hasSize && box.size.isEmpty;
  }

  bool _onlyEmpty(List<GuideTargetId> ids) {
    final mounted = [for (final id in ids) ?widget.locate(id)];
    return mounted.isNotEmpty && mounted.every(_isEmpty);
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

  void _track(Duration elapsed) {
    if (!mounted) return;
    final dt = math.min(
      (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond,
      AppMotion.guideSpringMaxStep,
    );
    _lastTick = elapsed;
    final origin = _origin;
    final size = origin?.size ?? MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final cardBox = _cardKey.currentContext?.findRenderObject();
    final cardHeight = cardBox is RenderBox && cardBox.hasSize
        ? cardBox.size.height
        : _cardHeight;

    final live = _liveHole(origin, size);
    final liveValues = [
      live.rect.left,
      live.rect.top,
      live.rect.right,
      live.rect.bottom,
      live.radius,
    ];
    var moved = false;
    for (var i = 0; i < _holeSprings.length; i++) {
      moved =
          _holeSprings[i].follow(liveValues[i], dt, snap: !_hasLanded) || moved;
    }
    final hole = _clip(
      GuideHole(
        Rect.fromLTRB(
          _holeSprings[0].value,
          _holeSprings[1].value,
          _holeSprings[2].value,
          _holeSprings[3].value,
        ),
        _holeSprings[4].value,
      ),
      size,
      padding,
    );

    final liveClipped = _clip(live, size, padding);
    _placement = _placementFor(liveClipped, cardHeight, size, padding);
    final cardWidth = size.width * _cardWidthFactor;
    final targetX = _cardLeftFor(liveClipped, cardWidth, size);
    final targetY = _cardTopFor(liveClipped, cardHeight, size);
    moved = _cardX.follow(targetX, dt, snap: !_hasLanded) || moved;
    moved = _cardY.follow(targetY, dt, snap: !_hasLanded) || moved;

    if (!moved && hole == _hole && cardHeight == _cardHeight) return;
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

  GuideHole _liveHole(RenderBox? origin, Size size) {
    final entry = _entry;
    final rect = entry == null || !entry.context.mounted
        ? null
        : _rectOf(
            entry.context,
            origin,
          )?.inflate(entry.padding).shift(_pendingScroll);
    if (entry != null && rect != null) {
      _lastCenter = rect.center;
      return GuideHole(rect, entry.radius + entry.padding);
    }
    return GuideHole.collapsed(
      _lastCenter ?? Offset(size.width / 2, size.height),
    );
  }

  Offset get _pendingScroll {
    final position = _scroll;
    final destination = _scrollTo;
    if (position == null || destination == null || !position.hasPixels) {
      return Offset.zero;
    }
    final shift = position.pixels - destination;
    return position.axis == Axis.vertical ? Offset(0, shift) : Offset(shift, 0);
  }

  double _floorOf(Size size) =>
      size.height -
      AppBottomNavBar.bottomInsetOf(context) -
      AppBottomNavBar.height;

  GuideHole _clip(GuideHole hole, Size size, EdgeInsets padding) {
    final rect = hole.rect;
    final top = math.max(rect.top, padding.top);
    final bottom = math.min(rect.bottom, _floorOf(size));
    if (bottom <= top) {
      return GuideHole.collapsed(
        Offset(
          rect.center.dx,
          rect.center.dy.clamp(padding.top, _floorOf(size)),
        ),
      );
    }
    return GuideHole(
      Rect.fromLTRB(
        math.max(rect.left, AppSpacing.xs),
        top,
        math.min(rect.right, size.width - AppSpacing.xs),
        bottom,
      ),
      hole.radius,
    );
  }

  void _handleTap(TapUpDetails details) {
    if (!_ready || _entry == null) return;
    if (_hole.contains(details.localPosition)) widget.onNext();
  }

  _CardPlacement _placementFor(
    GuideHole hole,
    double cardHeight,
    Size size,
    EdgeInsets padding,
  ) {
    if (_entry == null || !hole.isVisible) return _CardPlacement.dock;
    final needed = cardHeight + _cardGap;
    final below = _floorOf(size) - AppSpacing.xl - hole.rect.bottom;
    final above = hole.rect.top - padding.top - AppSpacing.xl;
    if (below >= needed) return _CardPlacement.below;
    if (above >= needed) return _CardPlacement.above;
    return _CardPlacement.dock;
  }

  double _cardLeftFor(GuideHole hole, double cardWidth, Size size) {
    if (_placement == _CardPlacement.dock) return (size.width - cardWidth) / 2;
    final horizontal = AppSpacing.xl;
    return (hole.rect.center.dx - cardWidth / 2).clamp(
      horizontal,
      size.width - horizontal - cardWidth,
    );
  }

  double _cardTopFor(GuideHole hole, double cardHeight, Size size) {
    return switch (_placement) {
      _CardPlacement.below => hole.rect.bottom + _cardGap,
      _CardPlacement.above => hole.rect.top - _cardGap - cardHeight,
      _CardPlacement.dock => _floorOf(size) - AppSpacing.xl - cardHeight,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.view.step.hero) {
      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: GuideSpotlight(
              hole: _hole,
              dim: AppOpacity.guideWelcomeScrim,
            ),
          ),
          Center(
            child: GuideWelcome(
              view: widget.view,
              onNext: widget.onNext,
              onSkip: widget.onSkip,
            ),
          ),
        ],
      );
    }

    final size = MediaQuery.sizeOf(context);
    final placement = _placement;
    final cardWidth = size.width * _cardWidthFactor;
    final left = _cardX.value;
    final caretInset = GuideCard.radius + GuideCard.caretWidth / 2;
    final caretOffset = (_hole.rect.center.dx - left).clamp(
      caretInset,
      cardWidth - caretInset,
    );

    final card = KeyedSubtree(
      key: _cardKey,
      child: GuideCard(
        view: widget.view,
        onNext: widget.onNext,
        onSkip: widget.onSkip,
        caretOffset: caretOffset,
        caret: switch (placement) {
          _CardPlacement.below => GuideCaret.up,
          _CardPlacement.above => GuideCaret.down,
          _CardPlacement.dock => GuideCaret.none,
        },
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleTap,
          child: GuideSpotlight(hole: _hole),
        ),
        Positioned(
          left: left,
          top: _cardY.value,
          width: cardWidth,
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

class _Spring {
  double value = 0;
  double velocity = 0;

  bool follow(double target, double dt, {required bool snap}) {
    if (snap || dt <= 0) {
      final changed = value != target;
      value = target;
      velocity = 0;
      return changed;
    }
    const omega = AppMotion.guideSpringOmega;
    final offset = target - value;
    if (offset.abs() < AppMotion.guideSpringRest &&
        velocity.abs() < AppMotion.guideSpringRest) {
      final changed = value != target;
      value = target;
      velocity = 0;
      return changed;
    }
    velocity += (omega * omega * offset - 2 * omega * velocity) * dt;
    value += velocity * dt;
    return true;
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
