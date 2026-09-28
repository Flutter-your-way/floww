import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:floww/config/widgets/theme/sheet_theme.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

Future<T?> showAppFloatingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool centered = false,
}) {
  final forcedMode = SheetTheme.forcedModeOf(context);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppFloatingSheet.transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => SheetTheme(
      forcedMode: forcedMode,
      child: Builder(builder: builder),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SheetTheme(
        forcedMode: forcedMode,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FadeTransition(
                opacity: curved,
                child: const _SheetBackdrop(),
              ),
            ),
            if (centered)
              FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: AppMotion.popRevealScale,
                    end: 1,
                  ).animate(curved),
                  child: child,
                ),
              )
            else
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
          ],
        ),
      );
    },
  );
}

class AppFloatingSheet extends StatelessWidget {
  const AppFloatingSheet({
    super.key,
    required this.child,
    this.frosted = false,
    this.alignment = Alignment.bottomCenter,
  });

  static const transitionDuration = Duration(milliseconds: 320);
  static const _resizeDuration = Duration(milliseconds: 250);
  static const double _frostBlurSigma = AppSizes.s24;

  final Widget child;
  final bool frosted;
  final AlignmentGeometry alignment;

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
        alignment: alignment,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: AppShapes.decoration(
                color: frosted
                    ? context.colors.backgroundSecondary.withValues(
                        alpha: AppOpacity.frostedSheet,
                      )
                    : context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: frosted
                    ? BorderSide(color: context.colors.borderGlow, width: 1)
                    : BorderSide.none,
              ),
              child: BackdropFilter(
                enabled: frosted,
                filter: ImageFilter.blur(
                  sigmaX: _frostBlurSigma,
                  sigmaY: _frostBlurSigma,
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
