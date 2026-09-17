import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_outlined_button.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FlowScoreCard extends StatelessWidget {
  const FlowScoreCard({
    super.key,
    required this.percent,
    this.recoveryLevel,
    this.todayMode,
    this.onStartWorkout,
    this.onBreakdownTap,
    this.onRecoveryTap,
    this.onModeTap,
  });

  final int percent;
  final String? recoveryLevel;
  final AppThemeMode? todayMode;
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2218), Color(0xFF93D500)],
        ),
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
                _FlowScoreBar(fraction: percent / 100),
                SizedBox(height: AppSpacing.lg),
                if (percent == 0)
                  ..._buildEmptyState(context)
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$percent',
                        style: context.textTheme.displayLarge?.copyWith(
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '%',
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (recoveryLevel != null)
                        _StatColumn(
                          label: 'RECOVERY',
                          value: recoveryLevel!,
                          showDot: true,
                          onTap: onRecoveryTap,
                        ),
                      if (recoveryLevel != null && todayMode != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Container(
                            width: 1,
                            height: AppSizes.s32,
                            color: context.colors.borderSubtle,
                          ),
                        ),
                      if (todayMode != null)
                        _StatColumn(
                          label: "TODAY'S MODE",
                          value: todayMode!.name.toUpperCase(),
                          showDot: false,
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
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('0', style: context.textTheme.displayLarge?.copyWith(height: 1)),
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '%',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: AppSpacing.lg),
      Text(
        'Complete your first workout to unlock your Flow Score.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      CustomOutlinedButton(text: 'Start Workout', onPressed: onStartWorkout),
    ];
  }
}

class _FlowScoreBar extends StatelessWidget {
  const _FlowScoreBar({required this.fraction});

  final double fraction;

  static const double _trackHeight = 24;
  static const double _thumbSize = 30;

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
                  gradient: LinearGradient(
                    stops: [0.1, 0.5, 1.0],
                    colors: [
                      Color(0xFF84B814),
                      Color(0xFFC3FF3D),
                      Color(0xFFFFFFFF),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.full),
                    bottomLeft: Radius.circular(AppRadius.full),
                  ),
                ),
              ),
              if (fraction > 0)
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
                            alpha: 0.6,
                          ),
                          blurRadius: 6,
                          spreadRadius: 1,
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.showDot,
    this.onTap,
  });

  final String label;
  final String value;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.info_outline,
              size: AppSizes.s12,
              color: context.colors.textSecondary,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            if (showDot) ...[
              Container(
                width: AppSizes.s8,
                height: AppSizes.s8,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              value,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
