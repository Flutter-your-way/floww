import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/wave/models/wave_reveal.dart';

class WaveStreamingText extends StatefulWidget {
  const WaveStreamingText({
    super.key,
    required this.text,
    this.style,
    this.animate = false,
    this.onRevealed,
  });

  final String text;
  final TextStyle? style;
  final bool animate;
  final VoidCallback? onRevealed;

  @override
  State<WaveStreamingText> createState() => _WaveStreamingTextState();
}

class _WaveStreamingTextState extends State<WaveStreamingText>
    with SingleTickerProviderStateMixin {
  late List<String> _tokens = WaveReveal.tokensOf(widget.text);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WaveReveal.durationFor(widget.text),
    value: widget.animate ? 0 : 1,
  )..addStatusListener(_onStatus);

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WaveStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    _tokens = WaveReveal.tokensOf(widget.text);
    _controller.value = 1;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onRevealed?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final color = style.color ?? context.colors.textPrimary;
    final textScaler = MediaQuery.textScalerOf(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final revealed =
            _controller.value *
            (_tokens.length + AppMotion.waveRevealFadeWords);
        var visibleLength = 0;
        final spans = <TextSpan>[];

        for (var index = 0; index < _tokens.length; index++) {
          final token = _tokens[index];
          final opacity = ((revealed - index) / AppMotion.waveRevealFadeWords)
              .clamp(0.0, 1.0);
          if (opacity > 0) visibleLength += token.length;
          spans.add(
            TextSpan(
              text: token,
              style: style.copyWith(
                color: color.withValues(alpha: color.a * opacity),
              ),
            ),
          );
        }

        return AnimatedSize(
          duration: AppMotion.waveRevealGrow,
          curve: AppMotion.waveRevealGrowCurve,
          alignment: Alignment.topLeft,
          child: _RevealHeight(
            visibleLength: visibleLength,
            child: RichText(
              textScaler: textScaler,
              text: TextSpan(style: style, children: spans),
            ),
          ),
        );
      },
    );
  }
}

class _RevealHeight extends SingleChildRenderObjectWidget {
  const _RevealHeight({required this.visibleLength, required super.child});

  final int visibleLength;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRevealHeight(visibleLength);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRevealHeight renderObject,
  ) {
    renderObject.visibleLength = visibleLength;
  }
}

class _RenderRevealHeight extends RenderProxyBox {
  _RenderRevealHeight(this._visibleLength);

  int _visibleLength;

  set visibleLength(int value) {
    if (value == _visibleLength) return;
    _visibleLength = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, _visibleHeightOf(child)),
    );
  }

  double _visibleHeightOf(RenderBox child) {
    if (child is! RenderParagraph) return child.size.height;
    final length = child.text.toPlainText(includeSemanticsLabels: false).length;
    if (_visibleLength >= length) return child.size.height;

    final position = TextPosition(offset: _visibleLength);
    final top = child.getOffsetForCaret(position, Rect.zero).dy;
    return math.min(
      child.size.height,
      top + child.getFullHeightForCaret(position),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }
}
