import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/stats/app_stat_column.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FlowScoreCard extends StatelessWidget {
  const FlowScoreCard({
    super.key,
    required this.percent,
    required this.recoveryLevel,
    required this.todayMode,
    this.hasRecoveryData = true,
    this.onStartWorkout,
    this.onBreakdownTap,
    this.onRecoveryTap,
    this.onModeTap,
  });

  final int percent;
  final String recoveryLevel;
  final bool hasRecoveryData;
  final AppThemeMode todayMode;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onBreakdownTap;
  final VoidCallback? onRecoveryTap;
  final VoidCallback? onModeTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBreakdownTap,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: context.colors.borderGlow, width: 1),
        gradient: context.gradients.darkGlow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    context.colors.backgroundSurface,
                    context.colors.backgroundSurface.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: context.colors.primary,
                      size: AppSizes.s20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Flow Score', style: context.textTheme.titleLarge),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                _AnimatedFlowScoreBar(percent: percent),
                SizedBox(height: AppSpacing.lg),
                if (percent == 0)
                  ..._buildEmptyState(context)
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _AnimatedFlowScoreValue(percent: percent),
                      Text(
                        '%',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      AppStatColumn(
                        label: 'RECOVERY',
                        value: recoveryLevel,
                        dotColor: hasRecoveryData
                            ? context.colors.success
                            : context.colors.textSecondary,
                        showInfoIcon: true,
                        onTap: onRecoveryTap,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Container(
                          width: AppSizes.s1,
                          height: AppSizes.s32,
                          color: context.colors.borderSubtle,
                        ),
                      ),
                      AppStatColumn(
                        label: "TODAY'S MODE",
                        value: todayMode.name.toUpperCase(),
                        showInfoIcon: true,
                        onTap: onModeTap,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEmptyState(BuildContext context) {
    return [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '0',
                      style: AppTypography.displayNumericSmall.copyWith(
                        height: 1,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      '%',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              width: AppSpacing.xl4,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your first workout to unlock your Flow Score.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  IntrinsicWidth(
                    child: PillButton(
                      variant: PillButtonVariant.glass,
                      height: AppSizes.s32,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      label: 'Start Workout',
                      labelStyle: AppTypography.bodySmallSemiBold,
                      labelColor: context.colors.primary,
                      onPressed: onStartWorkout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _AnimatedFlowScoreBar extends StatelessWidget {
  const _AnimatedFlowScoreBar({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percent / 100),
      duration: AppMotion.medium,
      curve: AppMotion.expandCurve,
      builder: (context, value, child) => _FlowScoreBar(fraction: value),
    );
  }
}

class _AnimatedFlowScoreValue extends StatelessWidget {
  const _AnimatedFlowScoreValue({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percent.toDouble()),
      duration: AppMotion.medium,
      curve: AppMotion.expandCurve,
      builder: (context, value, child) => Text(
        '${value.round()}',
        style: context.textTheme.displayLarge?.copyWith(height: 1),
      ),
    );
  }
}

class _FlowScoreBar extends StatelessWidget {
  const _FlowScoreBar({required this.fraction});

  final double fraction;

  static const double _trackHeight = 24;
  static const double _thumbSize = 30;
  static const double _hotZoneWidth = 88;
  static const double _fillGlow = 0.3;
  static const double _thumbGlow = 0.6;

  Gradient _fillGradient(BuildContext context, double fillWidth) {
    final colors = context.colors;
    final hotStart = fillWidth <= 0
        ? 0.0
        : ((fillWidth - _hotZoneWidth) / fillWidth).clamp(0.0, 1.0);

    return LinearGradient(
      colors: [colors.primaryDeep, colors.primary, colors.textPrimary],
      stops: [0, hotStart, 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thumbSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final fillWidth = (trackWidth * fraction.clamp(0.0, 1.0));
          final thumbLeft = (fillWidth - _thumbSize / 5).clamp(
            0.0,
            trackWidth - _thumbSize,
          );

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: _trackHeight,
                decoration: AppShapes.decoration(
                  color: context.colors.backgroundSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              Container(
                height: _trackHeight,
                width: fillWidth,
                decoration: AppShapes.decoration(
                  gradient: _fillGradient(context, fillWidth),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.full),
                    bottomLeft: Radius.circular(AppRadius.full),
                  ),
                  shadows: [
                    BoxShadow(
                      color: context.colors.primary.withValues(
                        alpha: _fillGlow,
                      ),
                      blurRadius: AppSizes.s20,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: thumbLeft,
                child: Container(
                  width: _thumbSize / 5,
                  height: _thumbSize,
                  decoration: AppShapes.decoration(
                    color: context.colors.primary,
                    side: BorderSide(
                      color: context.colors.textPrimary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    shadows: [
                      BoxShadow(
                        color: context.colors.textPrimary.withValues(
                          alpha: _thumbGlow,
                        ),
                        blurRadius: AppSizes.s6,
                        spreadRadius: AppSizes.s1,
                      ),
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.4),
                        blurRadius: AppSizes.s12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
