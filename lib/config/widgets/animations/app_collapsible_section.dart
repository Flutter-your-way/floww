import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class AppCollapsibleSection extends StatefulWidget {
  const AppCollapsibleSection({
    super.key,
    required this.visible,
    required this.child,
    this.gap = 0,
    this.animateIn = false,
    this.duration = AppMotion.expand,
  });

  final bool visible;
  final Widget child;
  final double gap;
  final bool animateIn;
  final Duration duration;

  @override
  State<AppCollapsibleSection> createState() => _AppCollapsibleSectionState();
}

class _AppCollapsibleSectionState extends State<AppCollapsibleSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.visible && !widget.animateIn ? 1 : 0,
  );

  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.expandCurve,
    reverseCurve: AppMotion.collapseCurve,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.fadeIn,
    reverseCurve: AppMotion.fadeIn,
  );

  @override
  void initState() {
    super.initState();
    if (widget.visible && widget.animateIn) _controller.forward();
  }

  @override
  void didUpdateWidget(AppCollapsibleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _size.value,
            child: Opacity(opacity: _fade.value, child: child),
          ),
        );
      },
      child: _AppCollapsibleContent(gap: widget.gap, child: widget.child),
    );
  }
}

class _AppCollapsibleContent extends StatelessWidget {
  const _AppCollapsibleContent({required this.gap, required this.child});

  final double gap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [SizedBox(height: gap), child],
    );
  }
}
