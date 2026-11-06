// ─────────────────────────────────────────────────────────────────────────────
//  liquid_glass.dart — iOS 26 Liquid Glass tab bar + glass button for Flutter
//
//  Two looks, one widget:
//    • LiquidGlassStyle.glass  — App Store: a clear glass capsule floating over
//      your content. The page behind is frosted, saturated and veiled, and
//      bent at the bar's rim and by the selection lens.
//    • LiquidGlassStyle.dark   — Photos: an opaque dark capsule.
//
//  The selection behaves like iOS 26:
//    • at rest the selected tab sits in a soft pill, its glyph tinted
//    • press → the pill lifts into a glass lens (one slot + 28.5pt wide,
//      ~11pt taller than the bar), the bar swells 7%; under the lens each tab
//      item is magnified ×1.175 about its OWN centre (glyphs stay put while
//      the lens slides); the rim refracts with the profile fitted to iOS:
//        – flat top/bottom: the strip just outside is stretched over the lip
//        – curved ends: a wide inward pull → content swells and wraps around
//          the curve in growing circles, with a mirrored fold at the very rim
//    • drag → glued to the finger, haptic tick per tab; release → springs home
//
//  Zero dependencies. Two shaders (see README for pubspec):
//    shaders/liquid_glass_lens.frag      — glyphs, pill, lens rim light
//    shaders/liquid_glass_backdrop.frag  — the glass over your page (Impeller)
//  Without Impeller (or if a shader can't load) it falls back gracefully.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  Shader loading
// ═════════════════════════════════════════════════════════════════════════════

/// Loads (once) and caches the fragment programs.
///
/// Call `await LiquidGlass.precache();` in `main()` so the first frame is
/// already glass. Widgets also load them lazily.
class LiquidGlass {
  LiquidGlass._();

  /// Asset paths, as declared under `flutter: shaders:` in pubspec.yaml.
  static String lensAsset = 'shaders/liquid_glass_lens.frag';
  static String backdropAsset = 'shaders/liquid_glass_backdrop.frag';

  static ui.FragmentProgram? _lens;
  static ui.FragmentProgram? _backdrop;
  static Future<void>? _loading;
  static final ValueNotifier<int> _loaded = ValueNotifier<int>(0);

  /// Loads both shaders. Safe to call many times.
  static Future<void> precache() => _loading ??= _doLoad();

  static Future<void> _doLoad() async {
    _lens = await _tryLoad(lensAsset);
    _backdrop = await _tryLoad(backdropAsset);
    _loaded.value++;
  }

  static Future<ui.FragmentProgram?> _tryLoad(String asset) async {
    try {
      return await ui.FragmentProgram.fromAsset(asset);
    } catch (e) {
      debugPrint('LiquidGlass: shader "$asset" unavailable ($e). Using fallback.');
      return null;
    }
  }

  /// Whether the real glass (backdrop refraction) is running. Needs Impeller.
  static bool get backdropActive {
    if (_backdrop == null) return false;
    try {
      return ui.ImageFilter.isShaderFilterSupported;
    } catch (_) {
      return false;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Style
// ═════════════════════════════════════════════════════════════════════════════

/// Every visual and optical knob. Defaults are measured off iOS 26 (Photos
/// and App Store tab bars, frame by frame).
@immutable
class LiquidGlassStyle {
  const LiquidGlassStyle({
    this.refractsBackdrop = false,
    this.barColor = const Color(0xFF181818),
    this.barPressedColor = const Color(0xFF2A2A2A),
    this.borderColor = const Color(0x30FFFFFF),
    this.borderPressedColor = const Color(0x4AFFFFFF),
    this.pillColor = const Color(0xFF333234),
    this.glassTint = const Color(0x06FFFFFF),
    this.selectedColor = const Color(0xFF1EA0FF),
    this.unselectedColor = const Color(0xFFF2F0F2),
    this.rimColor = const Color(0xFFE6E6EC),
    this.rimStrength = 0.95,
    this.iridescence = 0.85,
    this.iconSize = 26,
    this.labelStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    this.iconLabelGap = 2,
    this.inset = 3.8,
    this.pillExtraWidth = 6,
    this.pressedZoom = 1.175,
    this.refraction = 1.0,
    this.refractionBlur = 0.33,
    this.dispersion = 1.0,
    this.lensGrowHeight = 11,
    this.lensExtraWidth = 28.5,
    this.barSwell = 1.07,
    this.frost = 5.5,
    this.saturation = 1.25,
    this.barRefraction = 0.8,
    this.backdropBlur = 0,
    this.shadow = const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  });

  /// iOS 26 Photos (dark, opaque capsule) — the default.
  static const LiquidGlassStyle dark = LiquidGlassStyle();

  /// iOS 26 light, opaque-ish capsule.
  static const LiquidGlassStyle light = LiquidGlassStyle(
    barColor: Color(0xEBF7F7F8),
    barPressedColor: Color(0xF5FFFFFF),
    borderColor: Color(0x1F000000),
    borderPressedColor: Color(0x29000000),
    pillColor: Color(0x14000000),
    glassTint: Color(0x0AFFFFFF),
    selectedColor: Color(0xFF0A84FF),
    unselectedColor: Color(0xFF1C1C1E),
    rimColor: Color(0xFFFFFFFF),
    rimStrength: 0.9,
    iridescence: 0.45,
    backdropBlur: 18,
    shadow: BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  );

  /// iOS 26 App Store: clear glass over your content (frosted, saturated,
  /// refracting). On a black page it looks exactly like [dark].
  static const LiquidGlassStyle glass = LiquidGlassStyle(
    refractsBackdrop: true,
    barColor: Color(0x18FFFFFF), //        9.4% white veil (measured)
    barPressedColor: Color(0x24FFFFFF),
    pillColor: Color(0x1EFFFFFF), //        +11.7% white (measured)
    glassTint: Color(0x04FFFFFF),
    selectedColor: Color(0xFF1CA5FF),
    unselectedColor: Color(0xFFF4F4F4),
    pillExtraWidth: 7.3,
    lensGrowHeight: 9.6,
    shadow: null,
  );

  /// Light-mode glass (white veil, dark glyphs).
  static const LiquidGlassStyle glassLight = LiquidGlassStyle(
    refractsBackdrop: true,
    barColor: Color(0x73FFFFFF),
    barPressedColor: Color(0x8CFFFFFF),
    borderColor: Color(0x80FFFFFF),
    borderPressedColor: Color(0xB3FFFFFF),
    pillColor: Color(0x14000000),
    glassTint: Color(0x0AFFFFFF),
    selectedColor: Color(0xFF0A84FF),
    unselectedColor: Color(0xFF1C1C1E),
    rimColor: Color(0xFFFFFFFF),
    iridescence: 0.5,
    saturation: 1.4,
    pillExtraWidth: 7.3,
    lensGrowHeight: 9.6,
    shadow: null,
  );

  /// true: real glass over the content behind (needs Impeller; frosted
  /// fallback otherwise). [barColor] is then the veil laid over the frost.
  /// Used by the [glass] and [glassLight] presets.
  final bool refractsBackdrop;

  /// Bar fill at rest (in [refractsBackdrop] mode: the veil over the frosted page).
  final Color barColor;

  /// Bar fill / veil while pressed.
  final Color barPressedColor;

  /// ≈1pt rim light around the bar at rest, brightest where the edge faces
  /// the top-left light or its opposite (like iOS).
  final Color borderColor;

  /// Rim light while pressed.
  final Color borderPressedColor;

  /// Fill of the resting selection pill.
  final Color pillColor;

  /// Tint of the glass body while it is a lens.
  final Color glassTint;

  final Color selectedColor;
  final Color unselectedColor;

  /// Specular rim colour of the lens.
  final Color rimColor;

  /// 0 … 1 strength of the lens rim light.
  final double rimStrength;

  /// 0 … 1 thin-film colour in the lens rim.
  final double iridescence;

  final double iconSize;
  final TextStyle labelStyle;
  final double iconLabelGap;

  /// Gap between the bar edge and the resting pill (iOS ≈ 3.8pt).
  final double inset;

  /// How much wider the resting pill is than one tab slot.
  final double pillExtraWidth;

  /// Magnification of each tab item under the lens, about the item's OWN
  /// tab centre (iOS: ×1.175).
  final double pressedZoom;

  /// Strength of the lens rim refraction (1.0 = fitted to iOS).
  final double refraction;

  /// Blur per point of bend in the lens (iOS ≈ 0.33).
  final double refractionBlur;

  /// 0 … 1 chromatic dispersion.
  final double dispersion;

  /// How much taller than the bar the lens gets (total, pt).
  final double lensGrowHeight;

  /// Lens width = one tab slot + this (pt). iOS: 28.5 in Photos and App Store.
  final double lensExtraWidth;

  /// Scale of the whole bar while pressed.
  final double barSwell;

  /// [refractsBackdrop] mode: frost radius (pt) of the page behind the bar.
  final double frost;

  /// [refractsBackdrop] mode: vibrancy (1 = none).
  final double saturation;

  /// [refractsBackdrop] mode: refraction at the bar's own rim (1 = like the lens).
  final double barRefraction;

  /// Opaque mode: optional frosted blur behind the bar (0 = none).
  final double backdropBlur;

  /// Drop shadow under the bar (null = none). Ignored in [refractsBackdrop] mode.
  final BoxShadow? shadow;

  LiquidGlassStyle copyWith({
    bool? refractsBackdrop,
    Color? barColor,
    Color? barPressedColor,
    Color? borderColor,
    Color? borderPressedColor,
    Color? pillColor,
    Color? glassTint,
    Color? selectedColor,
    Color? unselectedColor,
    Color? rimColor,
    double? rimStrength,
    double? iridescence,
    double? iconSize,
    TextStyle? labelStyle,
    double? iconLabelGap,
    double? inset,
    double? pillExtraWidth,
    double? pressedZoom,
    double? refraction,
    double? refractionBlur,
    double? dispersion,
    double? lensGrowHeight,
    double? lensExtraWidth,
    double? barSwell,
    double? frost,
    double? saturation,
    double? barRefraction,
    double? backdropBlur,
    BoxShadow? shadow,
  }) {
    return LiquidGlassStyle(
      refractsBackdrop: refractsBackdrop ?? this.refractsBackdrop,
      barColor: barColor ?? this.barColor,
      barPressedColor: barPressedColor ?? this.barPressedColor,
      borderColor: borderColor ?? this.borderColor,
      borderPressedColor: borderPressedColor ?? this.borderPressedColor,
      pillColor: pillColor ?? this.pillColor,
      glassTint: glassTint ?? this.glassTint,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      rimColor: rimColor ?? this.rimColor,
      rimStrength: rimStrength ?? this.rimStrength,
      iridescence: iridescence ?? this.iridescence,
      iconSize: iconSize ?? this.iconSize,
      labelStyle: labelStyle ?? this.labelStyle,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      inset: inset ?? this.inset,
      pillExtraWidth: pillExtraWidth ?? this.pillExtraWidth,
      pressedZoom: pressedZoom ?? this.pressedZoom,
      refraction: refraction ?? this.refraction,
      refractionBlur: refractionBlur ?? this.refractionBlur,
      dispersion: dispersion ?? this.dispersion,
      lensGrowHeight: lensGrowHeight ?? this.lensGrowHeight,
      lensExtraWidth: lensExtraWidth ?? this.lensExtraWidth,
      barSwell: barSwell ?? this.barSwell,
      frost: frost ?? this.frost,
      saturation: saturation ?? this.saturation,
      barRefraction: barRefraction ?? this.barRefraction,
      backdropBlur: backdropBlur ?? this.backdropBlur,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle &&
      other.refractsBackdrop == refractsBackdrop &&
      other.barColor == barColor &&
      other.barPressedColor == barPressedColor &&
      other.borderColor == borderColor &&
      other.borderPressedColor == borderPressedColor &&
      other.pillColor == pillColor &&
      other.glassTint == glassTint &&
      other.selectedColor == selectedColor &&
      other.unselectedColor == unselectedColor &&
      other.rimColor == rimColor &&
      other.rimStrength == rimStrength &&
      other.iridescence == iridescence &&
      other.iconSize == iconSize &&
      other.labelStyle == labelStyle &&
      other.iconLabelGap == iconLabelGap &&
      other.inset == inset &&
      other.pillExtraWidth == pillExtraWidth &&
      other.pressedZoom == pressedZoom &&
      other.refraction == refraction &&
      other.refractionBlur == refractionBlur &&
      other.dispersion == dispersion &&
      other.lensGrowHeight == lensGrowHeight &&
      other.lensExtraWidth == lensExtraWidth &&
      other.barSwell == barSwell &&
      other.frost == frost &&
      other.saturation == saturation &&
      other.barRefraction == barRefraction &&
      other.backdropBlur == backdropBlur &&
      other.shadow == shadow;

  @override
  int get hashCode => Object.hashAll([
        refractsBackdrop, barColor, barPressedColor, borderColor, borderPressedColor,
        pillColor, glassTint, selectedColor, unselectedColor, rimColor,
        rimStrength, iridescence, iconSize, labelStyle, iconLabelGap, inset,
        pillExtraWidth, pressedZoom, refraction, refractionBlur, dispersion,
        lensGrowHeight, lensExtraWidth, barSwell, frost, saturation,
        barRefraction, backdropBlur, shadow,
      ]);
}

// ═════════════════════════════════════════════════════════════════════════════
//  Tab item
// ═════════════════════════════════════════════════════════════════════════════

@immutable
class LiquidGlassTabItem {
  const LiquidGlassTabItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;

  /// Optional filled variant shown in the selected colour.
  final IconData? selectedIcon;

  /// Tab label; pass '' for an icon-only bar.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassTabItem &&
      other.icon == icon &&
      other.selectedIcon == selectedIcon &&
      other.label == label;

  @override
  int get hashCode => Object.hash(icon, selectedIcon, label);
}

// ═════════════════════════════════════════════════════════════════════════════
//  Shared slot geometry (iOS rules)
// ═════════════════════════════════════════════════════════════════════════════

/// Width of one tab slot: pills sit [LiquidGlassStyle.inset] from the bar
/// ends and are [LiquidGlassStyle.pillExtraWidth] wider than a slot.
double _slotWidth(double barWidth, int n, LiquidGlassStyle s) =>
    math.max(1.0, (barWidth - 2 * s.inset - s.pillExtraWidth) / math.max(1, n));

/// Left edge of slot 0.
double _slotsLeft(LiquidGlassStyle s) => s.inset + s.pillExtraWidth / 2;

double _slotCenter(int i, double barWidth, int n, LiquidGlassStyle s) =>
    _slotsLeft(s) + _slotWidth(barWidth, n, s) * (i + 0.5);

/// Margin around the bar covered by the backdrop filter (lens overflow,
/// swell, rubber-band).
double _backdropMargin(Size bar, LiquidGlassStyle s) =>
    20 + s.lensExtraWidth / 2 + s.lensGrowHeight / 2 +
    (s.barSwell - 1) * math.max(bar.width, bar.height) / 2;

// ═════════════════════════════════════════════════════════════════════════════
//  LiquidGlassTabBar
// ═════════════════════════════════════════════════════════════════════════════

/// iOS 26 Liquid Glass tab bar. It expands to the incoming width; the height
/// is fixed by [height] (iOS: 62).
class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.style = LiquidGlassStyle.dark,
    this.height = 62,
    this.haptics = true,
  });

  final List<LiquidGlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final LiquidGlassStyle style;
  final double height;
  final bool haptics;

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _Motion _motion = _Motion();
  final _GlassResources _res = _GlassResources();

  // springs (x is in un-swollen bar coordinates, logical px)
  final _Spring _x = _Spring(0, stiffness: 420, dampingRatio: 0.8, epsilon: 0.05);
  final _Spring _press = _Spring(0, stiffness: 520, dampingRatio: 0.68, epsilon: 0.0008);
  final _Spring _stretch = _Spring(0, stiffness: 260, dampingRatio: 0.42, epsilon: 0.0008);

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
  double get _slotW => _slotWidth(_width, _n, widget.style);
  double _center(int i) => _slotCenter(i, _width, _n, widget.style);

  int _nearest(double x) =>
      ((x - _slotsLeft(widget.style)) / _slotW - 0.5).round().clamp(0, math.max(0, _n - 1));

  @override
  void initState() {
    super.initState();
    _selected = widget.currentIndex.clamp(0, math.max(0, _n - 1));
    _hoverIndex = _selected;
    _ticker = createTicker(_onTick);
    LiquidGlass.precache();
    LiquidGlass._loaded.addListener(_motion.notify);
  }

  @override
  void didUpdateWidget(LiquidGlassTabBar old) {
    super.didUpdateWidget(old);
    final idx = widget.currentIndex.clamp(0, math.max(0, _n - 1));
    if (old.items.length != widget.items.length || old.style != widget.style) {
      _xReady = false;
    }
    if (idx != _selected && _pointer == null) {
      _selected = idx;
      _hoverIndex = idx;
      if (_xReady) {
        // Programmatic switch: lift, travel, settle — like iOS.
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
    LiquidGlass._loaded.removeListener(_motion.notify);
    _ticker.dispose();
    _motion.dispose();
    _res.dispose();
    super.dispose();
  }

  // ── gestures ──────────────────────────────────────────────────────────────

  void _onDown(PointerDownEvent e) {
    if (_pointer != null || _width <= 0 || _n == 0) return;
    _pointer = e.pointer;
    _downX = e.localPosition.dx;
    _moved = false;
    _releasing = false;
    final x = _downX;
    if (_nearest(x) == _selected) {
      _grabOffset = x - _x.value; // grab the lens where it is
    } else {
      _grabOffset = 0; // slide over to the finger
      _x.target = _clampDrag(x);
    }
    _x
      ..stiffness = 900
      ..dampingRatio = 0.86;
    _press
      ..stiffness = 520
      ..dampingRatio = 0.62
      ..target = 1;
    _hoverIndex = _nearest(_x.target);
    _kick();
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final x = e.localPosition.dx;
    if (!_moved && (x - _downX).abs() > 4) _moved = true;
    _x.target = _clampDrag(x - _grabOffset);
    final h = _nearest(_x.target);
    if (h != _hoverIndex) {
      _hoverIndex = h;
      if (widget.haptics) HapticFeedback.selectionClick();
    }
    _kick();
  }

  void _onUp(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    final idx = _moved ? _nearest(_x.target) : _nearest(e.localPosition.dx);
    _release(idx);
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
      if (widget.haptics) HapticFeedback.selectionClick();
      widget.onChanged(idx);
    }
  }

  double _clampDrag(double x) {
    final lo = _center(0);
    final hi = _center(_n - 1);
    if (x < lo) return lo - _rubber(lo - x);
    if (x > hi) return hi + _rubber(x - hi);
    return x;
  }

  double _rubber(double over) {
    final d = _slotW * 0.35;
    return d * (1 - 1 / (over / d * 0.55 + 1));
  }

  // ── simulation ────────────────────────────────────────────────────────────

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
      _releasing = false;
    } else {
      final steps = math.max(1, (dt / (1 / 240)).ceil());
      final h = dt / steps;
      for (var i = 0; i < steps; i++) {
        _x.step(h);
        _press.step(h);
        _stretch.target = (_x.velocity / 2600).clamp(-1.0, 1.0);
        _stretch.step(h);
      }
      if (_releasing) {
        _releaseClock += dt;
        final arrived = (_x.value - _x.target).abs() < 4 && _x.velocity.abs() < 160;
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
      ..stretch = _stretch.value;
    _motion.notify();

    if (_pointer == null && !_releasing && _x.atRest && _press.atRest && _stretch.atRest) {
      _x.snap();
      _press.snap();
      _stretch.snap();
      _motion
        ..x = _x.value
        ..press = _press.value
        ..stretch = 0;
      _motion.notify();
      _ticker.stop();
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return SizedBox(height: widget.height);
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final scaler = MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
    final family = DefaultTextStyle.of(context).style.fontFamily;
    final style = widget.style;
    final n = _n;

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth.isFinite ? constraints.maxWidth : n * 86.0 + 16.0;
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

      final children = <Widget>[
        if (style.refractsBackdrop)
          Positioned(
            left: -margin,
            top: -margin,
            right: -margin,
            bottom: -margin,
            child: _GlassBackdrop(
              motion: _motion,
              style: style,
              margin: margin,
              frameFor: (bar) => _tabFrame(bar, n, style, _motion),
            ),
          )
        else if (style.backdropBlur > 0 || style.shadow != null)
          Positioned.fill(
            child: _SwellingBackdrop(
              motion: _motion,
              swell: style.barSwell,
              blur: style.backdropBlur,
              shadow: style.shadow,
            ),
          ),
        CustomPaint(
          size: size,
          painter: _TabBarPainter(
            motion: _motion,
            res: _res,
            items: widget.items,
            style: style,
            dpr: dpr,
            textScaler: scaler.clamp(maxScaleFactor: 1.3),
            fontFamily: family,
          ),
          child: _semantics(),
        ),
      ];

      return SizedBox(
        width: w,
        height: widget.height,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: _onUp,
          onPointerCancel: _onCancel,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      );
    });
  }

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
      ],
    );
  }
}

/// Geometry of the bar + lens for one frame (bar-local coordinates).
_GlassFrame _tabFrame(Size size, int n, LiquidGlassStyle style, _Motion motion) {
  final g = math.max(0.0, motion.press); // may overshoot > 1 (balloon)
  final gc = g.clamp(0.0, 1.0);
  final barScale = 1 + (style.barSwell - 1) * g;
  final center = size.center(Offset.zero);
  final barRect = Rect.fromCenter(
    center: center,
    width: size.width * barScale,
    height: size.height * barScale,
  );
  final slotW = _slotWidth(size.width, n, style);
  final restHalf = Offset(
    (slotW + style.pillExtraWidth) / 2,
    math.max(1.0, size.height / 2 - style.inset),
  );
  final glassHalf = Offset(
    (slotW + style.lensExtraWidth) / 2,
    size.height / 2 + style.lensGrowHeight / 2,
  );
  var half = Offset.lerp(restHalf, glassHalf, g)!;
  final s = motion.stretch.abs() * gc;
  half = Offset(half.dx * (1 + 0.08 * s), half.dy * (1 - 0.03 * s));
  final lensCenter = Offset(center.dx + (motion.x - center.dx) * barScale, center.dy);
  return _GlassFrame(
    barRect: barRect,
    barScale: barScale,
    lensRect: Rect.fromCenter(center: lensCenter, width: half.dx * 2, height: half.dy * 2),
    glass: gc,
    itemZoom: 1 + (style.pressedZoom - 1) * gc,
    refraction: style.refraction,
    barRefraction: style.barRefraction,
    items: [_slotsLeft(style), slotW, n.toDouble(), size.height / 2],
    barColor: Color.lerp(style.barColor, style.barPressedColor, gc)!,
    borderColor: Color.lerp(style.borderColor, style.borderPressedColor, gc)!,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  LiquidGlassButton — the round glass button (e.g. Photos' search)
// ═════════════════════════════════════════════════════════════════════════════

class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 62,
    this.iconSize = 28,
    this.iconColor,
    this.style = LiquidGlassStyle.dark,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final LiquidGlassStyle style;
  final String? semanticLabel;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _Motion _motion = _Motion();
  final _GlassResources _res = _GlassResources();
  final _Spring _press = _Spring(0, stiffness: 520, dampingRatio: 0.6, epsilon: 0.0008);
  double? _lastTick;
  bool _down = false;
  double _holdClock = 0;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    LiquidGlass.precache();
    LiquidGlass._loaded.addListener(_motion.notify);
  }

  @override
  void dispose() {
    LiquidGlass._loaded.removeListener(_motion.notify);
    _ticker.dispose();
    _motion.dispose();
    _res.dispose();
    super.dispose();
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
    _holdClock += dt;
    if (!_down && _holdClock > 0.12 && _press.target != 0) {
      _press
        ..stiffness = 260
        ..dampingRatio = 0.75
        ..target = 0;
    }
    if (_reduceMotion) {
      _press
        ..target = 0
        ..snap();
    } else {
      final steps = math.max(1, (dt / (1 / 240)).ceil());
      for (var i = 0; i < steps; i++) {
        _press.step(dt / steps);
      }
    }
    _motion
      ..press = _press.value
      ..notify();
    if (!_down && _press.target == 0 && _press.atRest) {
      _press.snap();
      _motion
        ..press = 0
        ..notify();
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final enabled = widget.onPressed != null;
    final style = widget.style;
    final size = Size.square(widget.size);
    final margin = _backdropMargin(size, style);

    final children = <Widget>[
      if (style.refractsBackdrop)
        Positioned(
          left: -margin,
          top: -margin,
          right: -margin,
          bottom: -margin,
          child: _GlassBackdrop(
            motion: _motion,
            style: style,
            margin: margin,
            frameFor: (bar) => _buttonFrame(bar, style, _motion),
          ),
        )
      else if (style.backdropBlur > 0 || style.shadow != null)
        Positioned.fill(
          child: _SwellingBackdrop(
            motion: _motion,
            swell: 1.12,
            blur: style.backdropBlur,
            shadow: style.shadow,
          ),
        ),
      CustomPaint(
        size: size,
        painter: _ButtonPainter(
          motion: _motion,
          res: _res,
          icon: widget.icon,
          iconSize: widget.iconSize,
          iconColor: (widget.iconColor ?? style.unselectedColor)
              .withValues(alpha: enabled ? null : 0.35),
          style: style,
          dpr: dpr,
        ),
      ),
    ];

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled
            ? (_) {
                _down = true;
                _holdClock = 0;
                _press
                  ..stiffness = 520
                  ..dampingRatio = 0.6
                  ..target = 1;
                _kick();
              }
            : null,
        onPointerUp: enabled
            ? (e) {
                _down = false;
                _kick();
                final inside = (Offset.zero & size).inflate(12).contains(e.localPosition);
                if (inside) {
                  HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                }
              }
            : null,
        onPointerCancel: enabled
            ? (_) {
                _down = false;
                _kick();
              }
            : null,
        child: SizedBox.fromSize(
          size: size,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }
}

_GlassFrame _buttonFrame(Size size, LiquidGlassStyle style, _Motion motion) {
  final g = math.max(0.0, motion.press);
  final gc = g.clamp(0.0, 1.0);
  final barScale = 1 + 0.12 * g;
  final center = size.center(Offset.zero);
  final barRect = Rect.fromCenter(
      center: center, width: size.width * barScale, height: size.height * barScale);
  return _GlassFrame(
    barRect: barRect,
    barScale: barScale,
    lensRect: barRect.inflate(2 * g),
    glass: gc * 0.85,
    itemZoom: 1 + 0.08 * gc,
    refraction: style.refraction * 0.6,
    barRefraction: style.barRefraction,
    items: [0, size.width, 1, size.height / 2],
    barColor: Color.lerp(style.barColor, style.barPressedColor, gc)!,
    borderColor: Color.lerp(style.borderColor, style.borderPressedColor, gc)!,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  Internals: motion, springs, resources
// ═════════════════════════════════════════════════════════════════════════════

class _Motion extends ChangeNotifier {
  double x = 0;
  double press = 0;
  double stretch = 0;
  void notify() => notifyListeners();
}

/// Damped spring, unit mass, semi-implicit Euler.
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

  bool get atRest => (value - target).abs() < epsilon && velocity.abs() < epsilon * 10;

  void snap() {
    value = target;
    velocity = 0;
  }
}

/// Owns the glyph layout and the selected-colour glyph texture so they are
/// rebuilt only when size / style / items / DPR change — never per frame.
class _GlassResources {
  Object? _key;
  ui.Image? image;
  Rect texRect = Rect.zero;
  _Glyphs? glyphs;
  ui.FragmentShader? _shader;

  ui.FragmentShader? shader() {
    final p = LiquidGlass._lens;
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

/// Lays out icon + label for every tab, in both colours.
class _Glyphs {
  _Glyphs({
    required this.items,
    required this.style,
    required this.textScaler,
    required this.fontFamily,
    this.iconOnlySize,
  });

  final List<LiquidGlassTabItem> items;
  final LiquidGlassStyle style;
  final TextScaler textScaler;
  final String? fontFamily;

  /// When set, the item is a single centred icon of this size (button mode).
  final double? iconOnlySize;

  final List<_GlyphPair> _pairs = [];

  void layout(Size size) {
    for (final p in _pairs) {
      p.dispose();
    }
    _pairs.clear();
    final n = items.length;
    final slotW = iconOnlySize != null ? size.width : _slotWidth(size.width, n, style);
    for (var i = 0; i < n; i++) {
      final it = items[i];
      final iconSize = iconOnlySize ?? style.iconSize;
      TextPainter icon(IconData d, Color c) => TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(
              text: String.fromCharCode(d.codePoint),
              style: TextStyle(
                inherit: false,
                color: c,
                fontSize: iconSize,
                height: 1.0,
                fontFamily: d.fontFamily,
                package: d.fontPackage,
                fontFamilyFallback: d.fontFamilyFallback,
              ),
            ),
          )..layout();
      TextPainter? label(Color c) => it.label.isEmpty || iconOnlySize != null
          ? null
          : (TextPainter(
              textDirection: TextDirection.ltr,
              textScaler: textScaler,
              maxLines: 1,
              ellipsis: '…',
              text: TextSpan(
                text: it.label,
                style: TextStyle(fontFamily: fontFamily, color: c)
                    .merge(style.labelStyle)
                    .copyWith(color: c),
              ),
            )..layout(maxWidth: math.max(0, slotW + style.pillExtraWidth - 4)));

      final selIcon = icon(it.selectedIcon ?? it.icon, style.selectedColor);
      final unIcon = icon(it.icon, style.unselectedColor);
      final selLabel = label(style.selectedColor);
      final unLabel = label(style.unselectedColor);

      final labelH = unLabel?.height ?? 0;
      final gap = unLabel == null ? 0.0 : style.iconLabelGap;
      final total = unIcon.height + gap + labelH;
      final cx = iconOnlySize != null ? size.width / 2 : _slotsLeft(style) + slotW * (i + 0.5);
      final top = (size.height - total) / 2;
      _pairs.add(_GlyphPair(
        selIcon: selIcon,
        unIcon: unIcon,
        selLabel: selLabel,
        unLabel: unLabel,
        cx: cx,
        iconTop: top,
        labelTop: top + unIcon.height + gap,
      ));
    }
  }

  void paint(Canvas canvas, {required bool selected, double itemZoom = 1, double anchorY = 0}) {
    for (final p in _pairs) {
      if (itemZoom != 1) {
        canvas.save();
        canvas.translate(p.cx, anchorY);
        canvas.scale(itemZoom);
        canvas.translate(-p.cx, -anchorY);
      }
      final ic = selected ? p.selIcon : p.unIcon;
      ic.paint(canvas, Offset(p.cx - ic.width / 2, p.iconTop));
      final lb = selected ? p.selLabel : p.unLabel;
      lb?.paint(canvas, Offset(p.cx - lb.width / 2, p.labelTop));
      if (itemZoom != 1) canvas.restore();
    }
  }

  void dispose() {
    for (final p in _pairs) {
      p.dispose();
    }
    _pairs.clear();
  }
}

class _GlyphPair {
  _GlyphPair({
    required this.selIcon,
    required this.unIcon,
    required this.selLabel,
    required this.unLabel,
    required this.cx,
    required this.iconTop,
    required this.labelTop,
  });
  final TextPainter selIcon, unIcon;
  final TextPainter? selLabel, unLabel;
  final double cx, iconTop, labelTop;

  void dispose() {
    selIcon.dispose();
    unIcon.dispose();
    selLabel?.dispose();
    unLabel?.dispose();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Painting — glyph layer
// ═════════════════════════════════════════════════════════════════════════════

/// Everything the glass needs for one frame, in bar-local coordinates.
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
  final Rect barRect; // swollen bar
  final double barScale;
  final Rect lensRect;
  final double glass; // 0..1
  final double itemZoom; // per-item magnification
  final double refraction; // lens refraction multiplier
  final double barRefraction; // bar-rim refraction multiplier (glass mode)

  /// slot left, slot width, slot count, anchor y — unswollen local coords
  final List<double> items;
  final Color barColor;
  final Color borderColor;
}

const Offset _kLight = Offset(-0.5523, -0.8336); // same as the shaders

/// Sweep gradient for the bar's rim light: for every direction from the
/// centre, find the capsule's surface normal there and light it with
/// |n·L|^1.5 — bright along the top/bottom and the lower-right curve,
/// dim on the upper-right curve, exactly like the iOS bar.
ui.Gradient _rimGradient(Rect rect, Color color, double opacity) {
  const n = 96;
  var hx = rect.width / 2;
  var hy = rect.height / 2;
  final vertical = hy > hx;
  if (vertical) {
    final t = hx;
    hx = hy;
    hy = t;
  }
  final r = hy; // capsule
  final flat = hx - r;
  final colors = <Color>[];
  final stops = <double>[];
  for (var i = 0; i <= n; i++) {
    final th = i / n * 2 * math.pi;
    var dx = math.cos(th);
    var dy = math.sin(th);
    if (vertical) {
      final t = dx;
      dx = dy;
      dy = t;
    }
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
    if (vertical) {
      final t = nx;
      nx = ny;
      ny = t;
    }
    final s = math.pow((nx * _kLight.dx + ny * _kLight.dy).abs(), 1.5).toDouble();
    final k = (0.2 + 0.8 * s) * opacity;
    colors.add(color.withValues(alpha: (color.a * k).clamp(0.0, 1.0)));
    stops.add(i / n);
  }
  return ui.Gradient.sweep(rect.center, colors, stops, ui.TileMode.clamp, 0, 2 * math.pi);
}

List<double> _premul(Color c) => [c.r * c.a, c.g * c.a, c.b * c.a, c.a];

/// Glyph layer:
///  1. (opaque mode) bar fill + rim light + unselected glyphs, lens punched out
///  2. lens: pill / magnified, refracted selected glyphs / rim light
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
  final barRRect = RRect.fromRectAndRadius(f.barRect, Radius.circular(f.barRect.shortestSide / 2));
  final lensRRect = RRect.fromRectAndRadius(f.lensRect, Radius.circular(f.lensRect.shortestSide / 2));
  final barFill = drawBarFill ? f.barColor : const Color(0x00000000);

  void swell(Canvas c) {
    c.translate(center.dx, center.dy);
    c.scale(f.barScale);
    c.translate(-center.dx, -center.dy);
  }

  // 1 ─ bar + rim light + unselected glyphs, lens area erased
  canvas.saveLayer(f.barRect.inflate(2), Paint());
  if (barFill.a > 0) canvas.drawRRect(barRRect, Paint()..color = barFill);
  if (f.borderColor.a > 0) {
    // ≈1pt rim, brightest on its outermost third (measured off iOS).
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

  // 2 ─ lens
  final shader = res.shader();
  final image = res.image;
  if (shader != null && image != null) {
    final r = res.texRect;
    final bar = _premul(barFill);
    final pill = _premul(style.pillColor);
    final tint = _premul(style.refractsBackdropTint);
    final rim = style.rimColor;
    final bc = f.borderColor;
    final values = <double>[
      r.left, r.top, r.width, r.height, //                      0–3  uTexRect
      f.barRect.center.dx, f.barRect.center.dy, //               4–5  uBar.xy
      f.barRect.width / 2, f.barRect.height / 2, //             6–7  uBar.zw
      f.barRect.shortestSide / 2, //                             8    uBarRadius
      f.barScale, //                                             9    uBarScale
      f.lensRect.center.dx, f.lensRect.center.dy, //            10–11 uLens.xy
      f.lensRect.width / 2, f.lensRect.height / 2, //           12–13 uLens.zw
      f.lensRect.shortestSide / 2, //                           14   uLensRadius
      f.glass, //                                               15   uGlass
      f.itemZoom, //                                            16   uItemZoom
      f.refraction, //                                          17   uRefraction
      size.height / 61.5, //                                    18   uProfileScale
      style.dispersion, //                                      19   uDispersion
      ...bar, //                                                20–23
      ...pill, //                                               24–27
      ...tint, //                                               28–31
      rim.r, rim.g, rim.b, style.rimStrength * rim.a, //        32–35 uRim
      style.iridescence, //                                     36
      image.width.toDouble(), image.height.toDouble(), //       37–38 uTexPx
      bc.r, bc.g, bc.b, bc.a, //                                39–42 uBarRim
      ...f.items, //                                            43–46 uItems
      style.refractionBlur, //                                  47   uBlur
    ];
    for (var i = 0; i < values.length; i++) {
      // setFloat is index-based and works on every Flutter version;
      // newer SDKs also offer name-based setters.
      // ignore: deprecated_member_use
      shader.setFloat(i, values[i]);
    }
    shader.setImageSampler(0, image);
    canvas.drawRect(f.lensRect.inflate(1.5), Paint()..shader = shader);
    return;
  }

  // Fallback (shader not loaded / unsupported): magnified, clipped,
  // un-refracted lens with a painted rim.
  final g = f.glass;
  if (barFill.a > 0) canvas.drawRRect(lensRRect, Paint()..color = barFill);
  canvas.drawRRect(lensRRect, Paint()..color = Color.lerp(style.pillColor, style.refractsBackdropTint, g)!);
  canvas.save();
  canvas.clipRRect(lensRRect);
  swell(canvas);
  glyphs.paint(canvas, selected: true, itemZoom: f.itemZoom, anchorY: f.items[3]);
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
    required this.style,
    required this.dpr,
    required this.textScaler,
    required this.fontFamily,
  }) : super(repaint: motion);

  final _Motion motion;
  final _GlassResources res;
  final List<LiquidGlassTabItem> items;
  final LiquidGlassStyle style;
  final double dpr;
  final TextScaler textScaler;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || items.isEmpty) return;
    final margin = 8 * style.refraction + style.lensGrowHeight + 24;
    res.ensure(
      key: Object.hash(size, dpr, Object.hashAll(items), style, textScaler, fontFamily),
      size: size,
      dpr: dpr,
      margin: margin,
      buildGlyphs: () => _Glyphs(
        items: items,
        style: style,
        textScaler: textScaler,
        fontFamily: fontFamily,
      ),
    );
    _paintGlass(
      canvas,
      size,
      _tabFrame(size, items.length, style, motion),
      res,
      style,
      drawBarFill: !style.refractsBackdrop || !LiquidGlass.backdropActive,
    );
  }

  @override
  bool shouldRepaint(_TabBarPainter old) =>
      old.items != items ||
      old.style != style ||
      old.dpr != dpr ||
      old.textScaler != textScaler ||
      old.fontFamily != fontFamily;
}

class _ButtonPainter extends CustomPainter {
  _ButtonPainter({
    required this.motion,
    required this.res,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.style,
    required this.dpr,
  }) : super(repaint: motion);

  final _Motion motion;
  final _GlassResources res;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final LiquidGlassStyle style;
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // A one-item "bar" whose selected colour is the icon colour.
    final s = style.copyWith(
      selectedColor: iconColor,
      unselectedColor: iconColor,
      pillColor: const Color(0x00000000),
      inset: 0,
      pillExtraWidth: 0,
    );
    res.ensure(
      key: Object.hash(size, dpr, icon, iconSize, iconColor, style),
      size: size,
      dpr: dpr,
      margin: 8 * style.refraction + 24,
      buildGlyphs: () => _Glyphs(
        items: [LiquidGlassTabItem(icon: icon, label: '')],
        style: s,
        textScaler: TextScaler.noScaling,
        fontFamily: null,
        iconOnlySize: iconSize,
      ),
    );
    _paintGlass(
      canvas,
      size,
      _buttonFrame(size, style, motion),
      res,
      s,
      drawBarFill: !style.refractsBackdrop || !LiquidGlass.backdropActive,
    );
  }

  @override
  bool shouldRepaint(_ButtonPainter old) =>
      old.icon != icon ||
      old.iconSize != iconSize ||
      old.iconColor != iconColor ||
      old.style != style ||
      old.dpr != dpr;
}

// ═════════════════════════════════════════════════════════════════════════════
//  Painting — backdrop glass layer (glass mode)
// ═════════════════════════════════════════════════════════════════════════════

/// Runs liquid_glass_backdrop.frag over the page behind the bar via a
/// BackdropFilterLayer, repainting on every motion tick (no rebuilds). The
/// region is the bar inflated by [margin] so the lens can overflow; outside
/// the bar and lens the page passes through untouched.
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
        motion: motion,
        style: style,
        margin: margin,
        frameFor: frameFor,
        dpr: MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderGlassBackdrop renderObject) {
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
  _RenderGlassBackdrop({
    required _Motion motion,
    required this.style,
    required this.margin,
    required this.frameFor,
    required this.dpr,
  }) : _motion = motion;

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
  final LayerHandle<BackdropFilterLayer> _filter = LayerHandle<BackdropFilterLayer>();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _motion.addListener(markNeedsPaint);
    LiquidGlass._loaded.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _motion.removeListener(markNeedsPaint);
    LiquidGlass._loaded.removeListener(markNeedsPaint);
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
    final program = LiquidGlass._backdrop;

    if (program != null && LiquidGlass.backdropActive) {
      final sh = _shader ??= program.fragmentShader();
      final global = localToGlobal(Offset(margin, margin));
      final veil = _premul(f.barColor);
      final b = f.barRect;
      final l = f.lensRect;
      final v = <double>[
        margin * dpr, margin * dpr, //                         2–3  origin (clip mode)
        global.dx * dpr, global.dy * dpr, //                   4–5  origin (target mode)
        size.width * dpr, size.height * dpr, //                6–7  uClipPx
        dpr, //                                                8    uDpr
        b.center.dx, b.center.dy, b.width / 2, b.height / 2, // 9–12 uBar
        b.shortestSide / 2, //                                 13   uBarRadius
        l.center.dx, l.center.dy, l.width / 2, l.height / 2, // 14–17 uLens
        l.shortestSide / 2, //                                 18   uLensRadius
        f.glass, //                                            19   uGlass
        f.refraction, //                                       20   uLensRefraction
        f.barRefraction, //                                    21   uBarRefraction
        bar.height / 61.5, //                                  22   uProfileScale
        style.dispersion, //                                   23   uDispersion
        style.frost, //                                        24   uFrost
        ...veil, //                                            25–28 uVeil
        style.saturation, //                                   29   uSaturation
      ];
      for (var i = 0; i < v.length; i++) {
        // Floats 0–1 (u_size) are set by the engine.
        // ignore: deprecated_member_use
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
      // Fallback: frosted blur clipped to the (swollen) bar.
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

// ═════════════════════════════════════════════════════════════════════════════
//  Opaque mode: shadow + optional frosted backdrop that swells with the bar
// ═════════════════════════════════════════════════════════════════════════════

class _SwellingBackdrop extends StatelessWidget {
  const _SwellingBackdrop({
    required this.motion,
    required this.swell,
    required this.blur,
    required this.shadow,
  });

  final _Motion motion;
  final double swell;
  final double blur;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final radius = BorderRadius.circular(c.biggest.shortestSide / 2);
      Widget child = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: shadow == null ? null : [shadow!],
        ),
      );
      if (blur > 0) {
        child = Stack(fit: StackFit.expand, children: [
          child,
          ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: const SizedBox.expand(),
            ),
          ),
        ]);
      }
      return ListenableBuilder(
        listenable: motion,
        builder: (context, child) => Transform.scale(
          scale: 1 + (swell - 1) * math.max(0.0, motion.press),
          child: child,
        ),
        child: child,
      );
    });
  }
}
