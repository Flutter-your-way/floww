import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';
import 'package:floww/core/guide/models/guide_step.dart';

class GuideWelcome extends StatefulWidget {
  const GuideWelcome({
    super.key,
    required this.view,
    required this.onNext,
    required this.onSkip,
  });

  final GuideViewState view;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<GuideWelcome> createState() => _GuideWelcomeState();
}

class _GuideWelcomeState extends State<GuideWelcome>
    with SingleTickerProviderStateMixin {
  static const double _orbSize = AppSizes.s160 * 2.6;
  static const double _orbSlot = AppSizes.s160 * 1.5;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.guideWelcome,
  )..forward();

  Animation<double> _phase(double begin, double end) => CurvedAnimation(
    parent: _reveal,
    curve: Interval(begin, end, curve: AppMotion.guideEnterCurve),
  );

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mode = context.select<ThemeModeController, AppThemeMode>(
      (controller) => controller.mode,
    );
    final step = widget.view.step;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _orbSlot,
            child: OverflowBox(
              maxWidth: _orbSize,
              maxHeight: _orbSize,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: AppMotion.guideWelcomeOrbFrom,
                  end: 1,
                ).animate(_phase(0, 0.6)),
                child: FadeTransition(
                  opacity: _phase(0, 0.4),
                  child: AnimatedOrb(
                    size: _orbSize,
                    palette: AppOrbPalette.of(mode),
                    speaking: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl3),
          _GuideRise(
            animation: _phase(0.3, 0.7),
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              style: AppTypography.heading2Bold.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _GuideRise(
            animation: _phase(0.42, 0.82),
            child: Text(
              step.body,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumRegular.copyWith(
                color: colors.textSubtle,
                height: AppTypography.bodyLargeRegular.height,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl4),
          _GuideRise(
            animation: _phase(0.55, 1),
            child: Column(
              children: [
                PillButton(
                  variant: PillButtonVariant.primary,
                  height: AppSizes.s48,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                  onPressed: widget.onNext,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.view.nextLabel,
                        style: AppTypography.bodyMediumSemiBold.copyWith(
                          color: colors.backgroundSecondary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: AppSizes.s18,
                        color: colors.backgroundSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                PressScale(
                  onTap: widget.onSkip,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      widget.view.skipLabel,
                      style: AppTypography.bodySmallSemiBold.copyWith(
                        color: colors.textSubtle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideRise extends StatelessWidget {
  const _GuideRise({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotion.guideCardRise),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
