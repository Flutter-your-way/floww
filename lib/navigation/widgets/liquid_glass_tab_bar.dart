import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/utils/effects/liquid_glass_lens_shader.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';

@immutable
class LiquidGlassStyle {
  const LiquidGlassStyle({
    required this.barColor,
    required this.barPressedColor,
    required this.borderColor,
    required this.borderPressedColor,
    required this.pillColor,
    required this.glassTint,
    required this.selectedColor,
    required this.unselectedColor,
    required this.rimColor,
    required this.rimStrength,
    required this.iridescence,
    required this.iconSize,
    required this.labelStyle,
    required this.iconLabelGap,
    required this.inset,
    required this.pillExtraWidth,
    required this.pressedZoom,
    required this.refraction,
    required this.refractionBlur,
    required this.dispersion,
    required this.lensGrowHeight,
    required this.lensExtraWidth,
    required this.barSwell,
    required this.frost,
    required this.saturation,
    required this.barRefraction,
    required this.dragGrowWidth,
    required this.dragGrowHeight,
    required this.lensOverhang,
    this.showLabels = true,
  });

  final Color barColor;
  final Color barPressedColor;
  final Color borderColor;
  final Color borderPressedColor;
  final Color pillColor;
  final Color glassTint;
  final Color selectedColor;
  final Color unselectedColor;
  final Color rimColor;
  final double rimStrength;
  final double iridescence;
  final double iconSize;
  final TextStyle labelStyle;
  final double iconLabelGap;
  final double inset;
  final double pillExtraWidth;
  final double pressedZoom;
  final double refraction;
  final double refractionBlur;
  final double dispersion;
  final double lensGrowHeight;
  final double lensExtraWidth;
  final double barSwell;
  final double frost;
  final double saturation;
  final double barRefraction;
  final double dragGrowWidth;
  final double dragGrowHeight;
  final double lensOverhang;
  final bool showLabels;

  List<Object> get _props => [
    barColor,
    barPressedColor,
    borderColor,
    borderPressedColor,
    pillColor,
    glassTint,
    selectedColor,
    unselectedColor,
    rimColor,
    rimStrength,
    iridescence,
    iconSize,
    labelStyle,
    iconLabelGap,
    inset,
    pillExtraWidth,
    pressedZoom,
    refraction,
    refractionBlur,
    dispersion,
    lensGrowHeight,
    lensExtraWidth,
    barSwell,
    frost,
    saturation,
    barRefraction,
    dragGrowWidth,
    dragGrowHeight,
    lensOverhang,
    showLabels,
  ];

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);
}

@immutable
class LiquidGlassTabItem {
  const LiquidGlassTabItem({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassTabItem &&
      other.iconAsset == iconAsset &&
      other.label == label;

  @override
  int get hashCode => Object.hash(iconAsset, label);
}

double _slotWidth(double barWidth, int n, LiquidGlassStyle s) =>
    math.max(1.0, (barWidth - 2 * s.inset - s.pillExtraWidth) / math.max(1, n));

double _slotsLeft(LiquidGlassStyle s) => s.inset + s.pillExtraWidth / 2;

double _slotCenter(int i, double barWidth, int n, LiquidGlassStyle s) =>
    _slotsLeft(s) + _slotWidth(barWidth, n, s) * (i + 0.5);

double _backdropMargin(Size bar, LiquidGlassStyle s) =>
    20 +
    s.lensExtraWidth / 2 +
    s.lensGrowHeight / 2 +
    (s.barSwell - 1) * math.max(bar.width, bar.height) / 2;

class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    required this.style,
    required this.height,
    this.trailing,
    this.trailingExtent = 0,
    this.onTrailingSelected,
  });

  final List<LiquidGlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final LiquidGlassStyle style;
  final double height;
  final Widget? trailing;
  final double trailingExtent;
  final VoidCallback? onTrailingSelected;

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _Motion _motion = _Motion();
  final _GlassResources _res = _GlassResources();

  final _Spring _x = _Spring(
    0,
    stiffness: 420,
    dampingRatio: 0.8,
    epsilon: 0.05,
  );
  final _Spring _press = _Spring(
    0,
    stiffness: 520,
    dampingRatio: 0.68,
    epsilon: 0.0008,
  );
  final _Spring _stretch = _Spring(
    0,
    stiffness: 260,
    dampingRatio: 0.42,
    epsilon: 0.0008,
  );
  final _Spring _drag = _Spring(
    0,
    stiffness: 380,
    dampingRatio: 0.62,
    epsilon: 0.0008,
  );

  List<PictureInfo> _icons = const [];
  int _iconsVersion = 0;
  int _iconsRequest = 0;

  double _width = 0;
  bool _xReady = false;
  late int _selected;

  int? _pointer;
  double _grabOffset = 0;
  double _downX = 0;
  bool _moved = false;
  int _hoverIndex = 0;
  bool _releasing = false;
  double _releaseClock = 0;
  double? _lastTick;
  bool _reduceMotion = false;

  int get _n => widget.items.length;
  double get _slotsWidth => math.max(0.0, _width - widget.trailingExtent);
  double get _slotW => _slotWidth(_slotsWidth, _n, widget.style);
  double _center(int i) => _slotCenter(i, _slotsWidth, _n, widget.style);

  int _nearest(double x) => ((x - _slotsLeft(widget.style)) / _slotW - 0.5)
      .round()
      .clamp(0, math.max(0, _n - 1))
      .toInt();

  bool get _hasTrailing => widget.trailing != null && widget.trailingExtent > 0;

  double get _trailingCenter => _slotsWidth + widget.trailingExtent / 2;

  int _nearestAny(double x) {
    if (_hasTrailing && _n > 0) {
      final edge = (_center(_n - 1) + _trailingCenter) / 2;
      if (x > edge) return _n;
    }
    return _nearest(x);
  }

  double _targetOf(int idx) => idx >= _n ? _trailingCenter : _center(idx);

  int get _clampedIndex =>
      widget.currentIndex.clamp(0, math.max(0, _n - 1)).toInt();

  @override
  void initState() {
    super.initState();
    _selected = _clampedIndex;
    _hoverIndex = _selected;
    _ticker = createTicker(_onTick);
    LiquidGlassLensShader.preload();
    LiquidGlassLensShader.loaded.addListener(_motion.notify);
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final request = ++_iconsRequest;
    final infos = await Future.wait(
      widget.items.map(
        (item) => vg.loadPicture(SvgAssetLoader(item.iconAsset), null),
      ),
    );
    if (!mounted || request != _iconsRequest) {
      for (final info in infos) {
        info.picture.dispose();
      }
      return;
    }
    final old = _icons;
    setState(() {
      _icons = infos;
      _iconsVersion++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final info in old) {
        info.picture.dispose();
      }
    });
  }

  @override
  void didUpdateWidget(LiquidGlassTabBar old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.items, widget.items)) _loadIcons();
    if (old.items.length != widget.items.length ||
        old.style != widget.style ||
        old.trailingExtent != widget.trailingExtent) {
      _xReady = false;
    }
    final idx = _clampedIndex;
    if (idx != _selected && _pointer == null) {
      _selected = idx;
      _hoverIndex = idx;
      if (_xReady) {
        _x
          ..stiffness = 300
          ..dampingRatio = 0.66
          ..target = _center(idx);
        _press.target = 1;
        _releasing = true;
        _releaseClock = 0;
        _kick();
      }
    }
  }

  @override
  void dispose() {
    LiquidGlassLensShader.loaded.removeListener(_motion.notify);
    _ticker.dispose();
    _motion.dispose();
    _res.dispose();
    for (final info in _icons) {
      info.picture.dispose();
    }
    super.dispose();
  }

  void _onDown(PointerDownEvent e) {
    if (_pointer != null || _width <= 0 || _n == 0) return;
    _pointer = e.pointer;
    _downX = e.localPosition.dx;
    _moved = false;
    _releasing = false;
    final x = _downX;
    if (_nearestAny(x) == _selected) {
      _grabOffset = x - _x.value;
    } else {
      _grabOffset = 0;
      _x.target = _clampDrag(x);
    }
    _x
      ..stiffness = 900
      ..dampingRatio = 0.86;
    _press
      ..stiffness = 520
      ..dampingRatio = 0.62
      ..target = 1;
    _hoverIndex = _nearestAny(_x.target);
    _kick();
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final x = e.localPosition.dx;
    if (!_moved && (x - _downX).abs() > 4) _moved = true;
    _x.target = _clampDrag(x - _grabOffset);
    final h = _nearestAny(_x.target);
    if (h != _hoverIndex) {
      _hoverIndex = h;
      HapticManager.selection();
    }
    _kick();
  }

  void _onUp(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    final idx = _moved
        ? _nearestAny(_x.target)
        : _nearestAny(e.localPosition.dx);
    if (idx >= _n) {
      _returnHome();
      if (_moved) widget.onTrailingSelected?.call();
      return;
    }
    _release(idx);
  }

  void _returnHome() {
    _pointer = null;
    _x
      ..stiffness = 300
      ..dampingRatio = 0.62
      ..target = _center(_selected);
    _releasing = true;
    _releaseClock = 0;
    _hoverIndex = _selected;
    _kick();
  }

  void _onCancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    _release(_selected);
  }

  void _release(int idx) {
    _pointer = null;
    _x
      ..stiffness = 300
      ..dampingRatio = 0.62
      ..target = _center(idx);
    _releasing = true;
    _releaseClock = 0;
    final changed = idx != _selected;
    _selected = idx;
    _hoverIndex = idx;
    _kick();
    if (changed) {
      HapticManager.selection();
      widget.onChanged(idx);
    } else {
      HapticManager.soft();
    }
  }

  double _clampDrag(double x) {
    final lo = _center(0);
    final hi = _targetOf(_hasTrailing ? _n : _n - 1);
    if (x < lo) return lo - _rubber(lo - x);
    if (x > hi) return hi + _rubber(x - hi);
    return x;
  }

  double _rubber(double over) {
    final d = _slotW * 0.35;
    return d * (1 - 1 / (over / d * 0.55 + 1));
  }

  void _kick() {
    if (!_ticker.isActive) {
      _lastTick = null;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    var dt = _lastTick == null ? 1 / 60 : t - _lastTick!;
    _lastTick = t;
    dt = dt.clamp(0.0, 1 / 30);

    if (_reduceMotion) {
      _x.snap();
      _press
        ..target = 0
        ..snap();
      _stretch.snap();
      _drag
        ..target = 0
        ..snap();
      _releasing = false;
    } else {
      _drag.target = _pointer != null && _moved ? 1 : 0;
      final steps = math.max(1, (dt / (1 / 240)).ceil());
      final h = dt / steps;
      for (var i = 0; i < steps; i++) {
        _x.step(h);
        _press.step(h);
        _stretch.target = (_x.velocity / 2600).clamp(-1.0, 1.0);
        _stretch.step(h);
        _drag.step(h);
      }
      if (_releasing) {
        _releaseClock += dt;
        final arrived =
            (_x.value - _x.target).abs() < 4 && _x.velocity.abs() < 160;
        if ((arrived && _releaseClock > 0.12) || _releaseClock > 0.75) {
          _press
            ..stiffness = 240
            ..dampingRatio = 0.78
            ..target = 0;
          _releasing = false;
        }
      }
    }

    _motion
      ..x = _x.value
      ..press = _press.value
      ..stretch = _stretch.value
      ..drag = _drag.value;
    _motion.notify();

    if (_pointer == null &&
        !_releasing &&
        _x.atRest &&
        _press.atRest &&
        _stretch.atRest &&
        _drag.atRest) {
      _x.snap();
      _press.snap();
      _stretch.snap();
      _drag.snap();
      _motion
        ..x = _x.value
        ..press = _press.value
        ..stretch = 0
        ..drag = 0;
      _motion.notify();
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return SizedBox(height: widget.height);
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final scaler =
        (MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling).clamp(
          maxScaleFactor: 1.3,
        );
    final style = widget.style;
    final n = _n;
    final trailingExtent = widget.trailingExtent;
    final trailing = widget.trailing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final w = _fitWidth(available);
        if (w != _width) {
          _width = w;
          _xReady = false;
        }
        if (!_xReady) {
          _xReady = true;
          _x.value = _center(_selected);
          _x.target = _x.value;
          _x.velocity = 0;
          _motion.x = _x.value;
        }

        final size = Size(w, widget.height);
        final margin = _backdropMargin(size, style);

        final bar = SizedBox(
          width: w,
          height: widget.height,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _onDown,
            onPointerMove: _onMove,
            onPointerUp: _onUp,
            onPointerCancel: _onCancel,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -margin,
                  top: -margin,
                  right: -margin,
                  bottom: -margin,
                  child: _GlassBackdrop(
                    motion: _motion,
                    style: style,
                    margin: margin,
                    frameFor: (bar) =>
                        _tabFrame(bar, n, style, _motion, trailingExtent),
                  ),
                ),
                CustomPaint(
                  size: size,
                  painter: _TabBarPainter(
                    motion: _motion,
                    res: _res,
                    items: widget.items,
                    icons: _icons,
                    iconsVersion: _iconsVersion,
                    style: style,
                    dpr: dpr,
                    textScaler: scaler,
                    trailingExtent: trailingExtent,
                  ),
                  child: _semantics(),
                ),
                if (trailing != null)
                  Positioned.fill(
                    child: ListenableBuilder(
                      listenable: _motion,
                      builder: (context, child) => Transform.scale(
                        scale:
                            1 +
                            (style.barSwell - 1) * math.max(0.0, _motion.press),
                        child: child,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: trailingExtent,
                          height: widget.height,
                          child: Center(child: trailing),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        return SizedBox(
          width: available,
          height: widget.height,
          child: Center(child: bar),
        );
      },
    );
  }

  double _fitWidth(double available) =>
      math.max(0.0, available / widget.style.barSwell);

  Widget _semantics() {
    return Row(
      children: [
        for (var i = 0; i < _n; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == _selected,
              inMutuallyExclusiveGroup: true,
              label: widget.items[i].label,
              onTap: () => _release(i),
              child: const SizedBox.expand(),
            ),
          ),
        SizedBox(width: widget.trailingExtent),
      ],
    );
  }
}

_GlassFrame _tabFrame(
  Size size,
  int n,
  LiquidGlassStyle style,
  _Motion motion,
  double trailingExtent,
) {
  final g = math.max(0.0, motion.press);
  final gc = g.clamp(0.0, 1.0);
  final barScale = 1 + (style.barSwell - 1) * g;
  final center = size.center(Offset.zero);
  final barRect = Rect.fromCenter(
    center: center,
    width: size.width * barScale,
    height: size.height * barScale,
  );
  final slotW = _slotWidth(
    math.max(0.0, size.width - trailingExtent),
    n,
    style,
  );
  final glassHalf = Offset(
    (slotW + style.lensExtraWidth) / 2,
    size.height / 2 + style.lensGrowHeight / 2,
  );
  final dragAspect =
      glassHalf.dx *
      (1 + style.dragGrowWidth) /
      (glassHalf.dy + style.dragGrowHeight / 2);
  final restHalfY = math.max(1.0, size.height / 2 - style.inset);
  final restHalf = Offset(
    math.min(restHalfY * dragAspect, size.width / 2 - style.inset),
    restHalfY,
  );
  var half = Offset.lerp(restHalf, glassHalf, g)!;
  final s = motion.stretch.abs() * gc;
  half = Offset(half.dx * (1 + 0.08 * s), half.dy * (1 - 0.03 * s));
  final d = motion.drag.clamp(0.0, 1.2) * gc;
  half = Offset(
    half.dx * (1 + style.dragGrowWidth * d),
    half.dy + style.dragGrowHeight / 2 * d,
  );
  final edgeMin = style.inset + half.dx;
  final edgeMax = size.width - style.inset - half.dx;
  final hugged = edgeMin <= edgeMax
      ? motion.x.clamp(edgeMin, edgeMax)
      : motion.x;
  final lensX = ui.lerpDouble(hugged, motion.x, gc)!;
  var lensCenterX = center.dx + (lensX - center.dx) * barScale;
  final reachMin = barRect.left - style.lensOverhang + half.dx;
  final reachMax = barRect.right + style.lensOverhang - half.dx;
  if (reachMin <= reachMax) {
    lensCenterX = lensCenterX.clamp(reachMin, reachMax);
  }
  final lensCenter = Offset(lensCenterX, center.dy);
  return _GlassFrame(
    barRect: barRect,
    barScale: barScale,
    lensRect: Rect.fromCenter(
      center: lensCenter,
      width: half.dx * 2,
      height: half.dy * 2,
    ),
    glass: gc,
    itemZoom: 1 + (style.pressedZoom - 1) * gc,
    refraction: style.refraction,
    barRefraction: style.barRefraction,
    items: [_slotsLeft(style), slotW, n.toDouble(), size.height / 2],
    barColor: Color.lerp(style.barColor, style.barPressedColor, gc)!,
    borderColor: Color.lerp(style.borderColor, style.borderPressedColor, gc)!,
  );
}

class _Motion extends ChangeNotifier {
  double x = 0;
  double press = 0;
  double stretch = 0;
  double drag = 0;
  void notify() => notifyListeners();
}

class _Spring {
  _Spring(
    this.value, {
    required this.stiffness,
    required this.dampingRatio,
    required this.epsilon,
  }) : target = value;

  double value;
  double target;
  double velocity = 0;
  double stiffness;
  double dampingRatio;
  final double epsilon;

  void step(double dt) {
    final c = 2 * dampingRatio * math.sqrt(stiffness);
    final a = -stiffness * (value - target) - c * velocity;
    velocity += a * dt;
    value += velocity * dt;
  }

  bool get atRest =>
      (value - target).abs() < epsilon && velocity.abs() < epsilon * 10;

  void snap() {
    value = target;
    velocity = 0;
  }
}

class _GlassResources {
  Object? _key;
  ui.Image? image;
  Rect texRect = Rect.zero;
  _Glyphs? glyphs;
  ui.FragmentShader? _shader;

  ui.FragmentShader? shader() {
    final p = LiquidGlassLensShader.lens;
    if (p == null) return null;
    return _shader ??= p.fragmentShader();
  }

  void ensure({
    required Object key,
    required Size size,
    required double dpr,
    required _Glyphs Function() buildGlyphs,
    required double margin,
  }) {
    if (key == _key && image != null) return;
    _key = key;
    glyphs?.dispose();
    image?.dispose();
    final g = buildGlyphs()..layout(size);
    glyphs = g;

    texRect = (Offset.zero & size).inflate(margin);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr);
    canvas.translate(-texRect.left, -texRect.top);
    g.paint(canvas, selected: true);
    final picture = recorder.endRecording();
    image = picture.toImageSync(
      math.max(1, (texRect.width * dpr).ceil()),
      math.max(1, (texRect.height * dpr).ceil()),
    );
    picture.dispose();
  }

  void dispose() {
    glyphs?.dispose();
    image?.dispose();
    _shader?.dispose();
    image = null;
    glyphs = null;
    _shader = null;
  }
}

class _Glyphs {
  _Glyphs({
    required this.items,
    required this.icons,
    required this.style,
    required this.textScaler,
    required this.trailingExtent,
  });

  final List<LiquidGlassTabItem> items;
  final List<PictureInfo> icons;
  final LiquidGlassStyle style;
  final TextScaler textScaler;
  final double trailingExtent;

  final List<_GlyphSlot> _slots = [];

  void layout(Size size) {
    dispose();
    final n = items.length;
    final slotW = _slotWidth(
      math.max(0.0, size.width - trailingExtent),
      n,
      style,
    );
    for (var i = 0; i < n; i++) {
      final item = items[i];
      TextPainter? label(Color c) => !style.showLabels || item.label.isEmpty
          ? null
          : (TextPainter(
              textDirection: TextDirection.ltr,
              textScaler: textScaler,
              maxLines: 1,
              ellipsis: '…',
              text: TextSpan(
                text: item.label,
                style: style.labelStyle.copyWith(color: c),
              ),
            )..layout(maxWidth: math.max(0, slotW + style.pillExtraWidth - 4)));

      final selLabel = label(style.selectedColor);
      final unLabel = label(style.unselectedColor);
      final labelH = unLabel?.height ?? 0;
      final gap = unLabel == null ? 0.0 : style.iconLabelGap;
      final total = style.iconSize + gap + labelH;
      final top = (size.height - total) / 2;
      _slots.add(
        _GlyphSlot(
          icon: i < icons.length ? icons[i] : null,
          selLabel: selLabel,
          unLabel: unLabel,
          cx: _slotsLeft(style) + slotW * (i + 0.5),
          iconTop: top,
          labelTop: top + style.iconSize + gap,
        ),
      );
    }
  }

  void _paintIcon(Canvas canvas, PictureInfo info, Color color, Offset at) {
    final box = style.iconSize;
    final src = info.size;
    final scale = box / math.max(src.width, src.height);
    final dx = (box - src.width * scale) / 2;
    final dy = (box - src.height * scale) / 2;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, box, box),
      Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
    );
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawPicture(info.picture);
    canvas.restore();
    canvas.restore();
  }

  void paint(
    Canvas canvas, {
    required bool selected,
    double itemZoom = 1,
    double anchorY = 0,
  }) {
    final color = selected ? style.selectedColor : style.unselectedColor;
    for (final s in _slots) {
      if (itemZoom != 1) {
        canvas.save();
        canvas.translate(s.cx, anchorY);
        canvas.scale(itemZoom);
        canvas.translate(-s.cx, -anchorY);
      }
      final icon = s.icon;
      if (icon != null) {
        _paintIcon(
          canvas,
          icon,
          color,
          Offset(s.cx - style.iconSize / 2, s.iconTop),
        );
      }
      final lb = selected ? s.selLabel : s.unLabel;
      lb?.paint(canvas, Offset(s.cx - lb.width / 2, s.labelTop));
      if (itemZoom != 1) canvas.restore();
    }
  }

  void dispose() {
    for (final s in _slots) {
      s.dispose();
    }
    _slots.clear();
  }
}

class _GlyphSlot {
  _GlyphSlot({
    required this.icon,
    required this.selLabel,
    required this.unLabel,
    required this.cx,
    required this.iconTop,
    required this.labelTop,
  });

  final PictureInfo? icon;
  final TextPainter? selLabel;
  final TextPainter? unLabel;
  final double cx;
  final double iconTop;
  final double labelTop;

  void dispose() {
    selLabel?.dispose();
    unLabel?.dispose();
  }
}

class _GlassFrame {
  _GlassFrame({
    required this.barRect,
    required this.barScale,
    required this.lensRect,
    required this.glass,
    required this.itemZoom,
    required this.refraction,
    required this.barRefraction,
    required this.items,
    required this.barColor,
    required this.borderColor,
  });

  final Rect barRect;
  final double barScale;
  final Rect lensRect;
  final double glass;
  final double itemZoom;
  final double refraction;
  final double barRefraction;
  final List<double> items;
  final Color barColor;
  final Color borderColor;
}

const Offset _kLight = Offset(-0.5523, -0.8336);

ui.Gradient _rimGradient(Rect rect, Color color, double opacity) {
  const n = 96;
  final hx = rect.width / 2;
  final r = rect.height / 2;
  final flat = hx - r;
  final colors = <Color>[];
  final stops = <double>[];
  for (var i = 0; i <= n; i++) {
    final th = i / n * 2 * math.pi;
    final dx = math.cos(th);
    final dy = math.sin(th);
    double nx;
    double ny;
    final tFlat = dy.abs() > 1e-6 ? r / dy.abs() : double.infinity;
    if (tFlat.isFinite && (tFlat * dx).abs() <= flat) {
      nx = 0;
      ny = dy.sign;
    } else {
      final cx = flat * dx.sign;
      final b = dx * cx;
      final tt = b + math.sqrt(math.max(0.0, b * b - cx * cx + r * r));
      nx = (tt * dx - cx) / r;
      ny = (tt * dy) / r;
    }
    final s = math
        .pow((nx * _kLight.dx + ny * _kLight.dy).abs(), 1.5)
        .toDouble();
    final k = (0.2 + 0.8 * s) * opacity;
    colors.add(color.withValues(alpha: (color.a * k).clamp(0.0, 1.0)));
    stops.add(i / n);
  }
  return ui.Gradient.sweep(
    rect.center,
    colors,
    stops,
    ui.TileMode.clamp,
    0,
    2 * math.pi,
  );
}

List<double> _premul(Color c) => [c.r * c.a, c.g * c.a, c.b * c.a, c.a];

void _paintGlass(
  Canvas canvas,
  Size size,
  _GlassFrame f,
  _GlassResources res,
  LiquidGlassStyle style, {
  required bool drawBarFill,
}) {
  final glyphs = res.glyphs!;
  final center = size.center(Offset.zero);
  final barRRect = RRect.fromRectAndRadius(
    f.barRect,
    Radius.circular(f.barRect.shortestSide / 2),
  );
  final lensRRect = RRect.fromRectAndRadius(
    f.lensRect,
    Radius.circular(f.lensRect.shortestSide / 2),
  );
  final barFill = drawBarFill ? f.barColor : f.barColor.withValues(alpha: 0);

  void swell(Canvas c) {
    c.translate(center.dx, center.dy);
    c.scale(f.barScale);
    c.translate(-center.dx, -center.dy);
  }

  canvas.saveLayer(f.barRect.inflate(2), Paint());
  if (barFill.a > 0) canvas.drawRRect(barRRect, Paint()..color = barFill);
  if (f.borderColor.a > 0) {
    final rim = _rimGradient(f.barRect, f.borderColor, 0.6);
    canvas.drawRRect(
      barRRect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = rim,
    );
    canvas.drawRRect(
      barRRect.deflate(0.17),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.34
        ..shader = rim,
    );
  }
  canvas.save();
  swell(canvas);
  glyphs.paint(canvas, selected: false);
  canvas.restore();
  canvas.drawRRect(lensRRect, Paint()..blendMode = BlendMode.dstOut);
  canvas.restore();

  final shader = res.shader();
  final image = res.image;
  if (shader != null && image != null) {
    final r = res.texRect;
    final rim = style.rimColor;
    final bc = f.borderColor;
    final values = <double>[
      r.left,
      r.top,
      r.width,
      r.height,
      f.barRect.center.dx,
      f.barRect.center.dy,
      f.barRect.width / 2,
      f.barRect.height / 2,
      f.barRect.shortestSide / 2,
      f.barScale,
      f.lensRect.center.dx,
      f.lensRect.center.dy,
      f.lensRect.width / 2,
      f.lensRect.height / 2,
      f.lensRect.shortestSide / 2,
      f.glass,
      f.itemZoom,
      f.refraction,
      size.height / 61.5,
      style.dispersion,
      ..._premul(barFill),
      ..._premul(style.pillColor),
      ..._premul(style.glassTint),
      rim.r,
      rim.g,
      rim.b,
      style.rimStrength * rim.a,
      style.iridescence,
      image.width.toDouble(),
      image.height.toDouble(),
      bc.r,
      bc.g,
      bc.b,
      bc.a,
      ...f.items,
      style.refractionBlur,
    ];
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(i, values[i]);
    }
    shader.setImageSampler(0, image);
    canvas.drawRect(f.lensRect.inflate(1.5), Paint()..shader = shader);
    return;
  }

  final g = f.glass;
  if (barFill.a > 0) canvas.drawRRect(lensRRect, Paint()..color = barFill);
  canvas.drawRRect(
    lensRRect,
    Paint()..color = Color.lerp(style.pillColor, style.glassTint, g)!,
  );
  canvas.save();
  canvas.clipRRect(lensRRect);
  swell(canvas);
  glyphs.paint(
    canvas,
    selected: true,
    itemZoom: f.itemZoom,
    anchorY: f.items[3],
  );
  canvas.restore();
  if (g > 0.01) {
    canvas.drawRRect(
      lensRRect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          f.lensRect.topLeft,
          f.lensRect.bottomRight,
          [
            style.rimColor.withValues(alpha: 0.85 * g * style.rimStrength),
            style.rimColor.withValues(alpha: 0.15 * g * style.rimStrength),
            style.rimColor.withValues(alpha: 0.65 * g * style.rimStrength),
          ],
          const [0.0, 0.5, 1.0],
        ),
    );
  }
}

class _TabBarPainter extends CustomPainter {
  _TabBarPainter({
    required this.motion,
    required this.res,
    required this.items,
    required this.icons,
    required this.iconsVersion,
    required this.style,
    required this.dpr,
    required this.textScaler,
    required this.trailingExtent,
  }) : super(repaint: motion);

  final _Motion motion;
  final _GlassResources res;
  final List<LiquidGlassTabItem> items;
  final List<PictureInfo> icons;
  final int iconsVersion;
  final LiquidGlassStyle style;
  final double dpr;
  final TextScaler textScaler;
  final double trailingExtent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || items.isEmpty) return;
    res.ensure(
      key: Object.hash(
        size,
        dpr,
        Object.hashAll(items),
        iconsVersion,
        style,
        textScaler,
        trailingExtent,
      ),
      size: size,
      dpr: dpr,
      margin: 8 * style.refraction + style.lensGrowHeight + 24,
      buildGlyphs: () => _Glyphs(
        items: items,
        icons: icons,
        style: style,
        textScaler: textScaler,
        trailingExtent: trailingExtent,
      ),
    );
    _paintGlass(
      canvas,
      size,
      _tabFrame(size, items.length, style, motion, trailingExtent),
      res,
      style,
      drawBarFill: !LiquidGlassLensShader.backdropActive,
    );
  }

  @override
  bool shouldRepaint(_TabBarPainter old) =>
      old.iconsVersion != iconsVersion ||
      !listEquals(old.items, items) ||
      old.style != style ||
      old.dpr != dpr ||
      old.textScaler != textScaler ||
      old.trailingExtent != trailingExtent;
}

class _GlassBackdrop extends LeafRenderObjectWidget {
  const _GlassBackdrop({
    required this.motion,
    required this.style,
    required this.margin,
    required this.frameFor,
  });

  final _Motion motion;
  final LiquidGlassStyle style;
  final double margin;
  final _GlassFrame Function(Size bar) frameFor;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGlassBackdrop(
    motion,
    style: style,
    margin: margin,
    frameFor: frameFor,
    dpr: MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGlassBackdrop renderObject,
  ) {
    renderObject
      ..motion = motion
      ..style = style
      ..margin = margin
      ..frameFor = frameFor
      ..dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0
      ..markNeedsPaint();
  }
}

class _RenderGlassBackdrop extends RenderBox {
  _RenderGlassBackdrop(
    this._motion, {
    required this.style,
    required this.margin,
    required this.frameFor,
    required this.dpr,
  });

  _Motion _motion;
  _Motion get motion => _motion;
  set motion(_Motion value) {
    if (identical(value, _motion)) return;
    if (attached) {
      _motion.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _motion = value;
  }

  LiquidGlassStyle style;
  double margin;
  _GlassFrame Function(Size bar) frameFor;
  double dpr;

  ui.FragmentShader? _shader;
  final LayerHandle<ClipRectLayer> _clipRect = LayerHandle<ClipRectLayer>();
  final LayerHandle<ClipRRectLayer> _clipRRect = LayerHandle<ClipRRectLayer>();
  final LayerHandle<BackdropFilterLayer> _filter =
      LayerHandle<BackdropFilterLayer>();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _motion.addListener(markNeedsPaint);
    LiquidGlassLensShader.loaded.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _motion.removeListener(markNeedsPaint);
    LiquidGlassLensShader.loaded.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _clipRect.layer = null;
    _clipRRect.layer = null;
    _filter.layer = null;
    _shader?.dispose();
    _shader = null;
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final bar = Size(
      math.max(0.0, size.width - 2 * margin),
      math.max(0.0, size.height - 2 * margin),
    );
    if (bar.isEmpty) return;
    final f = frameFor(bar);
    final layer = _filter.layer ??= BackdropFilterLayer();
    final program = LiquidGlassLensShader.backdrop;

    if (program != null && LiquidGlassLensShader.backdropActive) {
      final sh = _shader ??= program.fragmentShader();
      final global = localToGlobal(Offset(margin, margin));
      final b = f.barRect;
      final l = f.lensRect;
      final v = <double>[
        margin * dpr,
        margin * dpr,
        global.dx * dpr,
        global.dy * dpr,
        size.width * dpr,
        size.height * dpr,
        dpr,
        b.center.dx,
        b.center.dy,
        b.width / 2,
        b.height / 2,
        b.shortestSide / 2,
        l.center.dx,
        l.center.dy,
        l.width / 2,
        l.height / 2,
        l.shortestSide / 2,
        f.glass,
        f.refraction,
        f.barRefraction,
        bar.height / 61.5,
        style.dispersion,
        style.frost,
        ..._premul(f.barColor),
        style.saturation,
      ];
      for (var i = 0; i < v.length; i++) {
        sh.setFloat(i + 2, v[i]);
      }
      layer.filter = ui.ImageFilter.shader(sh);
      _clipRRect.layer = null;
      _clipRect.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        (ctx, off) => ctx.pushLayer(layer, (c, o) {}, off),
        oldLayer: _clipRect.layer,
      );
    } else {
      final sigma = math.max(0.1, style.frost / 2);
      layer.filter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
      final r = f.barRect.shift(Offset(margin, margin));
      _clipRect.layer = null;
      _clipRRect.layer = context.pushClipRRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        RRect.fromRectAndRadius(r, Radius.circular(r.shortestSide / 2)),
        (ctx, off) => ctx.pushLayer(layer, (c, o) {}, off),
        oldLayer: _clipRRect.layer,
      );
    }
  }
}
