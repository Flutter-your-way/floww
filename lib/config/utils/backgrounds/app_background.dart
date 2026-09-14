import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppBackgroundMode { defaultMode, flow, steady, restore }

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.mode = AppBackgroundMode.defaultMode,
    this.isInner = false,
    this.safeAreaTop = true,
    this.scrollable = false,
  });

  final Widget child;
  final AppBackgroundMode mode;
  final bool isInner;
  final bool safeAreaTop;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final decoration = _decoration;

    if (scrollable) {
      return _ScrollableBackground(
        decoration: decoration,
        safeAreaTop: safeAreaTop,
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: decoration,
      child: SafeArea(
        top: safeAreaTop,
        bottom: false,
        left: false,
        right: false,
        child: child,
      ),
    );
  }

  BoxDecoration get _decoration {
    if (mode == AppBackgroundMode.defaultMode) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14110B), Color(0xFF0A0A0A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }

    return BoxDecoration(
      image: DecorationImage(image: AssetImage(_imagePath), fit: BoxFit.cover),
    );
  }

  String get _imagePath {
    switch (mode) {
      case AppBackgroundMode.flow:
        return isInner
            ? 'assets/images/floww_inner.png'
            : 'assets/images/floww_main.png';
      case AppBackgroundMode.steady:
        return isInner
            ? 'assets/images/steady_inner.png'
            : 'assets/images/steady_main.png';
      case AppBackgroundMode.restore:
        return isInner
            ? 'assets/images/restore_inner.png'
            : 'assets/images/restore_main.png';
      default:
        return 'assets/images/floww_main.png';
    }
  }
}

class _ScrollableBackground extends StatefulWidget {
  const _ScrollableBackground({
    required this.decoration,
    required this.safeAreaTop,
    required this.child,
  });

  final BoxDecoration decoration;
  final bool safeAreaTop;
  final Widget child;

  @override
  State<_ScrollableBackground> createState() => _ScrollableBackgroundState();
}

class _ScrollableBackgroundState extends State<_ScrollableBackground> {
  final ScrollController _controller = ScrollController();

  double get _backgroundShift =>
      _controller.hasClients ? math.max(0.0, _controller.offset) : 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -_backgroundShift),
            child: child,
          ),
          child: DecoratedBox(decoration: widget.decoration),
        ),
        SafeArea(
          top: widget.safeAreaTop,
          bottom: false,
          left: false,
          right: false,
          child: SingleChildScrollView(
            controller: _controller,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
