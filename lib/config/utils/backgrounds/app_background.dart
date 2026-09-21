import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/theme_controller.dart';

enum AppBackgroundMode {
  defaultMode,
  flow,
  steady,
  restore;

  static AppBackgroundMode of(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => AppBackgroundMode.flow,
    AppThemeMode.steady => AppBackgroundMode.steady,
    AppThemeMode.restore => AppBackgroundMode.restore,
  };

  static AppBackgroundMode active(BuildContext context) =>
      of(context.watch<ThemeModeController>().mode);
}

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required Widget this.child,
    this.mode = AppBackgroundMode.defaultMode,
    this.isInner = false,
    this.safeAreaTop = true,
    this.scrollable = false,
  }) : children = null,
       padding = null;

  const AppBackground.list({
    super.key,
    required List<Widget> this.children,
    this.padding,
    this.mode = AppBackgroundMode.defaultMode,
    this.isInner = false,
    this.safeAreaTop = true,
  }) : child = null,
       scrollable = true;

  final Widget? child;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;
  final AppBackgroundMode mode;
  final bool isInner;
  final bool safeAreaTop;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final layer = _BackgroundLayer(decoration: _decoration, modeKey: _modeKey);
    final items = children;

    if (items != null) {
      return _ListBackground(
        layer: layer,
        safeAreaTop: safeAreaTop,
        padding: padding,
        children: items,
      );
    }

    if (scrollable) {
      return _ScrollableBackground(
        layer: layer,
        safeAreaTop: safeAreaTop,
        child: child!,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        layer,
        SafeArea(
          top: safeAreaTop,
          bottom: false,
          left: false,
          right: false,
          child: child!,
        ),
      ],
    );
  }

  String get _modeKey => '${mode.name}_$isInner';

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
        return isInner ? AppImages.flowInner : AppImages.flowMain;
      case AppBackgroundMode.steady:
        return isInner ? AppImages.steadyInner : AppImages.steadyMain;
      case AppBackgroundMode.restore:
        return isInner ? AppImages.restoreInner : AppImages.restoreMain;
      default:
        return AppImages.flowMain;
    }
  }
}

class _BackgroundLayer extends StatefulWidget {
  const _BackgroundLayer({required this.decoration, required this.modeKey});

  final BoxDecoration decoration;
  final String modeKey;

  @override
  State<_BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<_BackgroundLayer> {
  late BoxDecoration _decoration = widget.decoration;
  late String _modeKey = widget.modeKey;

  @override
  void didUpdateWidget(covariant _BackgroundLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modeKey != _modeKey) _resolve();
  }

  Future<void> _resolve() async {
    final decoration = widget.decoration;
    final modeKey = widget.modeKey;
    final image = decoration.image?.image;

    if (image != null) {
      await precacheImage(image, context);
      if (!mounted || widget.modeKey != modeKey) return;
    }

    setState(() {
      _decoration = decoration;
      _modeKey = modeKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: AppMotion.modeShift,
        switchInCurve: AppMotion.expandCurve,
        switchOutCurve: AppMotion.collapseCurve,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          fit: StackFit.expand,
          children: [...previousChildren, ?currentChild],
        ),
        child: DecoratedBox(key: ValueKey(_modeKey), decoration: _decoration),
      ),
    );
  }
}

class _ListBackground extends StatefulWidget {
  const _ListBackground({
    required this.layer,
    required this.safeAreaTop,
    required this.padding,
    required this.children,
  });

  final Widget layer;
  final bool safeAreaTop;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  @override
  State<_ListBackground> createState() => _ListBackgroundState();
}

class _ListBackgroundState extends State<_ListBackground> {
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
          child: widget.layer,
        ),
        SafeArea(
          top: widget.safeAreaTop,
          bottom: false,
          left: false,
          right: false,
          child: ListView(
            controller: _controller,
            padding: widget.padding,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

class _ScrollableBackground extends StatefulWidget {
  const _ScrollableBackground({
    required this.layer,
    required this.safeAreaTop,
    required this.child,
  });

  final Widget layer;
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
          child: widget.layer,
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
