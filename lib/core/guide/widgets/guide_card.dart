import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/core/guide/models/guide_step.dart';

enum GuideCaret { none, up, down }

class GuideCard extends StatelessWidget {
  const GuideCard({
    super.key,
    required this.view,
    required this.onNext,
    required this.onSkip,
    this.caret = GuideCaret.none,
    this.caretOffset = 0,
  });

  static const double caretWidth = AppSizes.s18;
  static const double caretHeight = AppSizes.s8;
  static const double radius = AppRadius.xl;

  final GuideViewState view;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final GuideCaret caret;
  final double caretOffset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = BorderRadius.circular(radius);
    final fill = colors.backgroundSecondary.withValues(
      alpha: AppOpacity.frostedSheet,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        LiquidGlass(
          borderRadius: shape,
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
              color: fill,
              borderRadius: shape,
              side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
            ),
            child: ClipRSuperellipse(
              borderRadius: shape,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _GuideStepBadge(
                              index: view.index,
                              count: view.count,
                            ),
                            SizedBox(width: AppSpacing.lg),
                            Expanded(child: _GuideStepSwitcher(view: view)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xl),
                        _GuideCardFooter(
                          view: view,
                          onNext: onNext,
                          onSkip: onSkip,
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: InnerGlow(
                      color: colors.primary.withValues(
                        alpha: AppOpacity.softGlow,
                      ),
                      radius: radius,
                      blur: AppSizes.s16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (caret != GuideCaret.none)
          Positioned(
            left: caretOffset - caretWidth / 2,
            top: caret == GuideCaret.up ? AppSizes.s1 - caretHeight : null,
            bottom: caret == GuideCaret.down ? AppSizes.s1 - caretHeight : null,
            child: _GuideCaretShape(
              fill: Color.alphaBlend(fill, colors.backgroundPrimary),
              edge: colors.borderGlow,
              pointsUp: caret == GuideCaret.up,
            ),
          ),
      ],
    );
  }
}

class _GuideCaretShape extends StatelessWidget {
  const _GuideCaretShape({
    required this.fill,
    required this.edge,
    required this.pointsUp,
  });

  final Color fill;
  final Color edge;
  final bool pointsUp;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(GuideCard.caretWidth, GuideCard.caretHeight),
      painter: _GuideCaretPainter(fill: fill, edge: edge, pointsUp: pointsUp),
    );
  }
}

class _GuideCaretPainter extends CustomPainter {
  const _GuideCaretPainter({
    required this.fill,
    required this.edge,
    required this.pointsUp,
  });

  static const double _tipRound = AppSizes.s2;

  final Color fill;
  final Color edge;
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final tipY = pointsUp ? 0.0 : size.height;
    final baseY = pointsUp ? size.height : 0.0;
    final mid = size.width / 2;
    final lean = pointsUp ? _tipRound : -_tipRound;
    final outline = Path()
      ..moveTo(0, baseY)
      ..lineTo(mid - _tipRound, tipY + lean)
      ..quadraticBezierTo(mid, tipY, mid + _tipRound, tipY + lean)
      ..lineTo(size.width, baseY);
    canvas.drawPath(Path.from(outline)..close(), Paint()..color = fill);
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.s1
        ..color = edge,
    );
  }

  @override
  bool shouldRepaint(_GuideCaretPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.edge != edge ||
      oldDelegate.pointsUp != pointsUp;
}

class _GuideStepSwitcher extends StatelessWidget {
  const _GuideStepSwitcher({required this.view});

  final GuideViewState view;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.guideStep,
      curve: AppMotion.guideEnterCurve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: AppMotion.guideStep,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, ?current],
        ),
        child: _GuideStepContent(
          key: ValueKey('${view.flow.section.name}-${view.index}'),
          step: view.step,
        ),
      ),
    );
  }
}

class _GuideStepContent extends StatelessWidget {
  const _GuideStepContent({super.key, required this.step});

  final GuideStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: AppTypography.bodyLargeBold.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          step.body,
          style: AppTypography.bodySmallMedium.copyWith(
            color: colors.textSubtle,
          ),
        ),
      ],
    );
  }
}

class _GuideStepBadge extends StatelessWidget {
  const _GuideStepBadge({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;

    return SizedBox.square(
      dimension: AppSizes.s44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: AppOpacity.tintFill),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: (index + 1) / count),
          duration: AppMotion.guideCardGrow,
          curve: AppMotion.guideEnterCurve,
          builder: (context, progress, child) => CustomPaint(
            painter: _GuideRingPainter(progress: progress, color: accent),
            child: child,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: AppMotion.guideStep,
              switchInCurve: AppMotion.guideEnterCurve,
              transitionBuilder: (child, animation) => ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, child.key == ValueKey(index) ? 1 : -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              ),
              child: Text(
                '${index + 1}',
                key: ValueKey(index),
                style: AppTypography.heading4.copyWith(color: accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideRingPainter extends CustomPainter {
  const _GuideRingPainter({required this.progress, required this.color});

  static const double _stroke = AppSizes.s3;

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = color.withValues(alpha: AppOpacity.guideProgressTrack),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_GuideRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GuideCardFooter extends StatelessWidget {
  const _GuideCardFooter({
    required this.view,
    required this.onNext,
    required this.onSkip,
  });

  final GuideViewState view;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          view.flow.label,
          style: AppTypography.captionSemiBold.copyWith(
            color: context.colors.primary,
          ),
        ),
        const Spacer(),
        if (!view.isLast) ...[
          PressScale(
            onTap: onSkip,
            child: Text(
              view.skipLabel,
              style: AppTypography.bodySmallSemiBold.copyWith(
                color: context.colors.textSubtle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
        ],
        _GuideNextButton(
          label: view.nextLabel,
          isLast: view.isLast,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _GuideNextButton extends StatelessWidget {
  const _GuideNextButton({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.backgroundSecondary;

    return PillButton(
      variant: PillButtonVariant.primary,
      height: AppSizes.s36,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      onPressed: onTap,
      child: Row(
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
      ),
    );
  }
}
