import 'dart:ui' as ui;

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_mode_intensity.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/flow_mode/models/flow_mode_change.dart';
import 'package:floww/core/flow_mode/widgets/mode_orb_visual.dart';
import 'package:flutter/material.dart';

class FlowModeTransition extends StatefulWidget {
  const FlowModeTransition({
    super.key,
    required this.mode,
    required this.previousMode,
    this.onThemeApply,
    this.onCompleted,
  });

  final AppThemeMode mode;
  final AppThemeMode previousMode;
  final VoidCallback? onThemeApply;
  final VoidCallback? onCompleted;

  @override
  State<FlowModeTransition> createState() => _FlowModeTransitionState();
}

class _FlowModeTransitionState extends State<FlowModeTransition>
    with SingleTickerProviderStateMixin {
  static const double _copyAnchor = 0.5;
  static const double _burstHapticPoint = 0.52;

  late final AppModeIntensity _intensity = AppModeIntensity.of(widget.mode);
  late final AppColorTokens _colors = AppTheme.colorsOf(widget.mode);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _intensity.transitionDuration,
  );

  bool _reducedMotion = false;
  bool _started = false;
  bool _themeApplied = false;
  bool _burstFelt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;

    _started = true;
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) {
      _controller.duration = AppMotion.modeTransitionReduced;
    }

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _playEntryHaptic();
    _controller.forward();
  }

  void _playEntryHaptic() {
    switch (widget.mode) {
      case AppThemeMode.restore:
        HapticManager.soft();
      case AppThemeMode.steady:
        HapticManager.selection();
      case AppThemeMode.flow:
        HapticManager.medium();
    }
  }

  void _onTick() {
    final value = _controller.value;

    if (!_themeApplied && value >= AppMotion.modeThemeSwitchPoint) {
      _themeApplied = true;
      widget.onThemeApply?.call();
    }

    if (!_burstFelt &&
        !_reducedMotion &&
        widget.mode == AppThemeMode.flow &&
        value >= _burstHapticPoint) {
      _burstFelt = true;
      HapticManager.light();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AbsorbPointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _buildFrame(context),
        ),
      ),
    );
  }

  Widget _buildFrame(BuildContext context) {
    final value = _controller.value;
    final entry = AppMotion.modeVeilIn.transform(value);
    final release = AppMotion.modeVeilOut.transform(value);
    final veil = (entry * (1 - release)).clamp(0.0, 1.0);
    final content = (entry * (1 - AppMotion.modeContentOut.transform(value)))
        .clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_reducedMotion) _Veil(sigma: veil * AppMotion.modeVeilBlurSigma),
        ColoredBox(
          color: _colors.backgroundPrimary.withValues(
            alpha: veil * AppMotion.modeVeilOpacity,
          ),
        ),
        if (content > 0)
          Opacity(
            opacity: content,
            child: Transform.scale(
              scale: _reducedMotion
                  ? 1
                  : 1 + (AppMotion.modeReleaseScale - 1) * release,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildVisual(
                    _reducedMotion ? 1 : AppMotion.modeVisual.transform(value),
                  ),
                  _buildCopy(value),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVisual(double progress) {
    return ModeOrbVisual(
      mode: widget.mode,
      progress: progress,
      colors: _colors,
      intensity: _intensity,
      reducedMotion: _reducedMotion,
    );
  }

  Widget _buildCopy(double value) {
    final titleIn = AppMotion.modeTitleIn.transform(value);
    final messageIn = AppMotion.modeMessageIn.transform(value);

    return Align(
      alignment: const Alignment(0, _copyAnchor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CopyLine(
              progress: titleIn,
              reducedMotion: _reducedMotion,
              child: Text(
                FlowModeCopy.titleOf(widget.mode),
                textAlign: TextAlign.center,
                style: AppTypography.flowModeTitle.copyWith(
                  color: _colors.textPrimary,
                  letterSpacing: _intensity.titleTracking,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CopyLine(
              progress: messageIn,
              reducedMotion: _reducedMotion,
              child: Text(
                FlowModeCopy.messageOf(widget.mode),
                textAlign: TextAlign.center,
                style: AppTypography.flowModeMessage.copyWith(
                  color: _colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Veil extends StatelessWidget {
  const _Veil({required this.sigma});

  final double sigma;

  @override
  Widget build(BuildContext context) {
    if (sigma <= AppSizes.hairline) return const SizedBox.expand();

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: const SizedBox.expand(),
    );
  }
}

class _CopyLine extends StatelessWidget {
  const _CopyLine({
    required this.progress,
    required this.reducedMotion,
    required this.child,
  });

  final double progress;
  final bool reducedMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducedMotion) return Opacity(opacity: progress, child: child);

    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, AppMotion.modeCopyRise * (1 - progress)),
        child: Transform.scale(
          scale:
              AppMotion.modeCopyScale +
              (1 - AppMotion.modeCopyScale) * progress,
          child: child,
        ),
      ),
    );
  }
}
