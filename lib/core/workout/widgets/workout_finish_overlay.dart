import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/animated_value_text.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class WorkoutFinishOverlay extends StatefulWidget {
  const WorkoutFinishOverlay({
    super.key,
    required this.isDone,
    required this.summary,
  });

  final bool isDone;
  final WorkoutFinishSummary summary;

  @override
  State<WorkoutFinishOverlay> createState() => _WorkoutFinishOverlayState();
}

class _WorkoutFinishOverlayState extends State<WorkoutFinishOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: AppMotion.expand,
  )..forward();
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.workoutFinishMin,
  );
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: AppMotion.workoutFinishMin,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.workoutFinishPulse,
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    if (widget.isDone) {
      _reveal.value = 1;
      _fill.value = 1;
      HapticManager.success();
    } else {
      _reveal.forward();
      _fill.animateTo(
        AppMotion.workoutFinishLoadingFill,
        curve: AppMotion.enter,
      );
    }
  }

  @override
  void didUpdateWidget(WorkoutFinishOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDone && !oldWidget.isDone) {
      _reveal.forward();
      _fill.animateTo(
        1,
        duration: AppMotion.medium,
        curve: AppMotion.expandCurve,
      );
      HapticManager.success();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _reveal.dispose();
    _fill.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Animation<double> _rowAnimation(int index) {
    final begin = (index * AppMotion.workoutFinishRowStep).clamp(0.0, 1.0);
    final end = (begin + AppMotion.workoutFinishRowSpan).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _reveal,
      curve: Interval(begin, end, curve: AppMotion.enter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final summary = widget.summary;
    final stats = summary.stats;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: AppMotion.enter),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: AppMotion.modeVeilBlurSigma,
          sigmaY: AppMotion.modeVeilBlurSigma,
        ),
        child: ColoredBox(
          color: colors.scrim,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FinishStatus(
                      label: summary.statusLabel,
                      isDone: widget.isDone,
                      pulse: _pulse,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading1.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl4),
                    for (var i = 0; i < stats.length; i++)
                      _FinishReveal(
                        animation: _rowAnimation(i),
                        child: _FinishRow(
                          label: stats[i].label,
                          value: _CountUpValue(
                            stat: stats[i],
                            animation: _rowAnimation(i),
                          ),
                        ),
                      ),
                    _FinishReveal(
                      animation: _rowAnimation(stats.length),
                      child: _FinishRow(
                        label: summary.flowLabel,
                        value: _FlowValue(
                          value: summary.flowValue,
                          delta: summary.flowDelta,
                          pulse: _pulse,
                        ),
                      ),
                    ),
                    _FinishBar(progress: _fill),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishStatus extends StatelessWidget {
  const _FinishStatus({
    required this.label,
    required this.isDone,
    required this.pulse,
  });

  final String label;
  final bool isDone;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isDone ? colors.primary : colors.textSecondary;

    return Row(
      children: [
        SizedBox.square(
          dimension: AppSizes.s16,
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            switchInCurve: AppMotion.pop,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    key: const ValueKey(true),
                    size: AppSizes.s16,
                    color: colors.primary,
                  )
                : Center(
                    key: const ValueKey(false),
                    child: FadeTransition(
                      opacity: pulse,
                      child: Container(
                        width: AppSizes.s8,
                        height: AppSizes.s8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        AnimatedValueText(
          value: label,
          style: AppTypography.labelMediumSemiBold.copyWith(color: color),
        ),
      ],
    );
  }
}

class _FinishReveal extends StatelessWidget {
  const _FinishReveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotion.workoutFinishRowRise),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _FinishRow extends StatelessWidget {
  const _FinishRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.borderSubtle, width: AppSizes.hairline),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            value,
          ],
        ),
      ),
    );
  }
}

class _CountUpValue extends StatelessWidget {
  const _CountUpValue({required this.stat, required this.animation});

  final WorkoutFinishStat stat;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unit = stat.unit;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final current = (stat.value * animation.value).round();
        final text = stat.isClock
            ? NumberFormatter.clock(current)
            : NumberFormatter.grouped(current);
        return Text.rich(
          TextSpan(
            text: text,
            children: [
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: AppTypography.bodyLargeMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
          style: AppTypography.bodyLargeSemiBold.copyWith(
            color: colors.textPrimary,
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

class _FlowValue extends StatelessWidget {
  const _FlowValue({
    required this.value,
    required this.delta,
    required this.pulse,
  });

  final String? value;
  final String? delta;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = this.value;
    final delta = this.delta;

    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.enter,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: value == null
          ? FadeTransition(
              key: const ValueKey(false),
              opacity: pulse,
              child: Container(
                width: AppSizes.s40,
                height: AppSizes.s8,
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            )
          : Row(
              key: const ValueKey(true),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.bodyLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (delta != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Text(
                    delta,
                    style: AppTypography.bodyLargeSemiBold.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _FinishBar extends StatelessWidget {
  const _FinishBar({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.full);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: AppSizes.s4,
        color: colors.backgroundElevated,
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => FractionallySizedBox(
            widthFactor: progress.value,
            heightFactor: 1,
            child: ColoredBox(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
