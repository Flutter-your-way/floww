import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/animations/typewriter_text.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/config/widgets/progress/page_dots.dart';
import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/widgets/guide_title_reveal.dart';

class GuideCard extends StatelessWidget {
  const GuideCard({
    super.key,
    required this.view,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.revealed = true,
  });

  final GuideViewState view;
  final bool revealed;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.xl);

    return LiquidGlass(
      borderRadius: radius,
      blurSigma: AppGlass.blurSigma,
      fillOpacity: AppGlass.fillOpacity,
      shadows: [
        BoxShadow(
          color: colors.primary.withValues(alpha: AppOpacity.buttonGlow),
          blurRadius: AppSizes.s40,
          offset: const Offset(0, AppSizes.s12),
          spreadRadius: -AppSizes.s12,
        ),
      ],
      child: DecoratedBox(
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary.withValues(
            alpha: AppOpacity.frostedSheet,
          ),
          borderRadius: radius,
          side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
        ),
        child: ClipRSuperellipse(
          borderRadius: radius,
          child: Stack(
            children: [
              const Positioned(
                top: -AppSizes.s64,
                left: -AppSizes.s48,
                child: _GuideAurora(),
              ),
              Positioned(
                right: -AppSizes.s16,
                bottom: -AppSizes.s16,
                child: _GuideWatermark(icon: view.step.icon),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GuideCardHeader(view: view, onSkip: onSkip),
                    SizedBox(height: AppSpacing.lg),
                    _GuideStepSwitcher(view: view, revealed: revealed),
                    SizedBox(height: AppSpacing.lg),
                    _GuideCardFooter(
                      view: view,
                      onNext: onNext,
                      onBack: onBack,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: InnerGlow(
                  color: colors.primary.withValues(alpha: AppOpacity.softGlow),
                  radius: AppRadius.xl,
                  blur: AppSizes.s16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideAurora extends StatelessWidget {
  const _GuideAurora();

  static const double _sigma = AppSizes.s48;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: SizedBox.square(
          dimension: AppSizes.s160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withValues(
                alpha: AppOpacity.guideAurora,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideWatermark extends StatelessWidget {
  const _GuideWatermark({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: AppMotion.guideStep,
        child: Icon(
          icon,
          key: ValueKey(icon),
          size: AppSizes.s80,
          color: context.colors.primary.withValues(
            alpha: AppOpacity.guideWatermark,
          ),
        ),
      ),
    );
  }
}

class _GuideCardHeader extends StatelessWidget {
  const _GuideCardHeader({required this.view, required this.onSkip});

  final GuideViewState view;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mode = context.select<ThemeModeController, AppThemeMode>(
      (controller) => controller.mode,
    );

    return Row(
      children: [
        SizedBox.square(
          dimension: AppSizes.s28,
          child: OverflowBox(
            maxWidth: AppSizes.s40,
            maxHeight: AppSizes.s40,
            child: AnimatedOrb(
              size: AppSizes.s40,
              palette: AppOrbPalette.of(mode),
              playIntro: false,
              speaking: true,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WAVE',
                style: AppTypography.bodySmallBoldTight.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '${view.flow.label}  ·  ${view.index + 1} of ${view.count}',
                style: AppTypography.captionSemiBold.copyWith(
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: view.isLast ? 0 : 1,
          duration: AppMotion.guideStep,
          child: IgnorePointer(
            ignoring: view.isLast,
            child: PressScale(
              onTap: onSkip,
              child: Container(
                height: AppSizes.s24,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.center,
                decoration: AppShapes.decoration(
                  color: colors.borderSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  view.skipLabel,
                  style: AppTypography.captionSemiBold.copyWith(
                    color: colors.textSubtle,
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

class _GuideStepSwitcher extends StatelessWidget {
  const _GuideStepSwitcher({required this.view, required this.revealed});

  final GuideViewState view;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final currentKey = ValueKey('${view.flow.section.name}-${view.index}');

    return AnimatedSize(
      duration: AppMotion.guideStep,
      curve: AppMotion.guideEnterCurve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: AppMotion.guideStep,
        switchInCurve: AppMotion.guideEnterCurve,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == currentKey;
          final shift = AppMotion.guideStepShift * view.direction;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(isIncoming ? shift : -shift, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _GuideStepContent(
          key: currentKey,
          step: view.step,
          revealed: revealed,
        ),
      ),
    );
  }
}

class _GuideStepContent extends StatelessWidget {
  const _GuideStepContent({
    super.key,
    required this.step,
    required this.revealed,
  });

  final GuideStep step;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GuideTitleReveal(
          text: step.title,
          start: revealed,
          style: context.textTheme.titleLarge,
        ),
        SizedBox(height: AppSpacing.xs),
        TypewriterText(
          text: step.body,
          start: revealed,
          speed: AppMotion.guideTyping,
          style: AppTypography.bodyMediumRegular.copyWith(
            color: colors.textSubtle,
          ),
        ),
        if (step.highlights.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          AnimatedOpacity(
            opacity: revealed ? 1 : 0,
            duration: AppMotion.guideCardGrow,
            curve: AppMotion.guideCardGrowCurve,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final highlight in step.highlights)
                  AppStatusChip(
                    label: highlight,
                    variant: AppStatusChipVariant.outlined,
                    height: AppSizes.s20,
                    labelStyle: AppTypography.captionSemiBold,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GuideCardFooter extends StatelessWidget {
  const _GuideCardFooter({
    required this.view,
    required this.onNext,
    required this.onBack,
  });

  final GuideViewState view;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PageDots(count: view.count, activeIndex: view.index),
        const Spacer(),
        AnimatedSize(
          duration: AppMotion.guideStep,
          curve: AppMotion.guideEnterCurve,
          child: view.isFirst
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(right: AppSpacing.md),
                  child: _GuideBackButton(onTap: onBack),
                ),
        ),
        PillButton(
          variant: PillButtonVariant.primary,
          height: AppSizes.s36,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          onPressed: onNext,
          child: _GuideNextLabel(label: view.nextLabel, isLast: view.isLast),
        ),
      ],
    );
  }
}

class _GuideBackButton extends StatelessWidget {
  const _GuideBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(AppRadius.full),
        blurSigma: AppGlass.blurSigmaLight,
        refraction: AppGlass.refractionSoft,
        thickness: AppGlass.edgeThicknessTight,
        child: SizedBox.square(
          dimension: AppSizes.s36,
          child: Icon(
            Icons.arrow_back_rounded,
            size: AppSizes.s18,
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _GuideNextLabel extends StatelessWidget {
  const _GuideNextLabel({required this.label, required this.isLast});

  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.backgroundSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.bodySmallBoldTight.copyWith(color: color),
        ),
        SizedBox(width: AppSpacing.xs),
        Icon(
          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
          size: AppSizes.s16,
          color: color,
        ),
      ],
    );
  }
}
