import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

Future<T?> showAppFloatingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppFloatingSheet.transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: FadeTransition(
              opacity: curved,
              child: const _SheetBackdrop(),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        ],
      );
    },
  );
}

class AppFloatingSheet extends StatelessWidget {
  const AppFloatingSheet({super.key, required this.child});

  static const transitionDuration = Duration(milliseconds: 320);
  static const _resizeDuration = Duration(milliseconds: 250);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final horizontal = context.sizes.screenHorizontalPadding;
    final bottom = math.max(
      viewInsets.bottom + AppSpacing.md,
      viewPadding.bottom + AppSpacing.xs,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: horizontal,
        right: horizontal,
        top: viewPadding.top + AppSpacing.xl,
        bottom: bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: AppShapes.decoration(
              color: context.colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: AnimatedSize(
              duration: _resizeDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: _resizeDuration,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.bottomCenter,
                  children: [...previous, ?current],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetBackdrop extends StatelessWidget {
  const _SheetBackdrop();

  static const double _blurSigma = 10;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
      child: ColoredBox(color: context.colors.scrim),
    );
  }
}
