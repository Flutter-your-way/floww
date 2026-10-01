import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';

const double _orbBoxSize = AppSizes.s100 * 3;
const double _orbSize = AppSizes.s160 * 3;

class OnboardingAnalysisScreen extends StatelessWidget {
  const OnboardingAnalysisScreen({
    super.key,
    required this.title,
    required this.steps,
    this.error,
    this.onRetry,
    this.onBack,
  });

  final String title;
  final List<String> steps;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradientTokens.analysisBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: error == null ? 0 : 1,
                duration: AppMotion.fast,
                child: IgnorePointer(
                  ignoring: error == null,
                  child: CustomHeader(onBackPressed: onBack),
                ),
              ),
              Expanded(
                flex: 5,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox.square(
                      dimension: _orbBoxSize,
                      child: OverflowBox(
                        maxWidth: _orbSize,
                        maxHeight: _orbSize,
                        child: AnimatedOrb(
                          size: _orbSize,
                          palette: AppOrbPalette.flow,
                          showWave: true,
                          speaking: error == null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: AppMotion.analysisScreen,
                switchInCurve: AppMotion.analysisCurve,
                switchOutCurve: AppMotion.analysisCurve,
                child: error == null
                    ? _AnalysisProgress(
                        key: const ValueKey('analysis-progress'),
                        title: title,
                        steps: steps,
                      )
                    : AppErrorCard(
                        key: const ValueKey('analysis-error'),
                        message: error,
                        onRetry: onRetry,
                      ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisProgress extends StatefulWidget {
  const _AnalysisProgress({
    super.key,
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;

  @override
  State<_AnalysisProgress> createState() => _AnalysisProgressState();
}

class _AnalysisProgressState extends State<_AnalysisProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.profileAnalysis,
  )..forward();

  late final Animation<double> _titleIn = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.analysisTitleIn,
  );

  late final List<Animation<double>> _stepReveals = List.generate(
    widget.steps.length,
    (i) {
      final start =
          AppMotion.analysisStepsStart +
          i * AppMotion.analysisStepRevealStagger;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start,
          start + AppMotion.analysisStepRevealSpan,
          curve: AppMotion.analysisCurve,
        ),
      );
    },
  );

  double get _revealEnd =>
      AppMotion.analysisStepsStart +
      (widget.steps.length - 1) * AppMotion.analysisStepRevealStagger +
      AppMotion.analysisStepRevealSpan;

  double _doneAt(int index) =>
      _revealEnd +
      (index + 1) *
          (AppMotion.analysisStepsEnd - _revealEnd) /
          widget.steps.length;

  int get _doneCount {
    var count = 0;
    while (count < widget.steps.length && _controller.value >= _doneAt(count)) {
      count++;
    }
    return count;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RiseIn(
          animation: _titleIn,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final doneCount = _doneCount;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.lg,
              children: [
                for (var i = 0; i < widget.steps.length; i++)
                  _RiseIn(
                    animation: _stepReveals[i],
                    child: _AnalysisStepRow(
                      label: widget.steps[i],
                      done: i < doneCount,
                      distance: i - doneCount,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RiseIn extends StatelessWidget {
  const _RiseIn({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, (1 - animation.value) * AppMotion.analysisRise),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _AnalysisStepRow extends StatelessWidget {
  const _AnalysisStepRow({
    required this.label,
    required this.done,
    required this.distance,
  });

  final String label;
  final bool done;
  final int distance;

  static const double _activeOpacity = 0.6;
  static const double _nextOpacity = 0.35;
  static const double _queuedOpacity = 0.18;

  double get _opacity {
    if (done) return 1;
    return switch (distance) {
      0 => _activeOpacity,
      1 => _nextOpacity,
      _ => _queuedOpacity,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: AppMotion.analysisStep,
      curve: AppMotion.analysisCurve,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.lg,
        children: [
          _AnalysisStepIndicator(done: done),
          Text(
            label,
            style: AppTypography.labelLargeMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisStepIndicator extends StatelessWidget {
  const _AnalysisStepIndicator({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: AppSizes.s20,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedScale(
            scale: done ? 1 : 0,
            duration: AppMotion.analysisStep,
            curve: done ? AppMotion.pop : AppMotion.collapseCurve,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryDeep,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: AppSizes.s14,
                color: colors.backgroundPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
