import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class FlowScoreBarChart extends StatelessWidget {
  const FlowScoreBarChart({super.key, required this.days});

  static const double _trackHeight = 203;

  final List<FlowScoreDay> days;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in days) ...[
          Expanded(
            child: _FlowScoreBar(day: day, trackHeight: _trackHeight),
          ),
          if (day != days.last) SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class _FlowScoreBar extends StatelessWidget {
  const _FlowScoreBar({required this.day, required this.trackHeight});

  static const double _badgeHeight = AppSizes.s16;
  static const double _badgeOverlap = AppSizes.s4;
  static const double _badgeBorderWidth = AppSizes.s1;
  static const double _badgeShadowBlur = AppSizes.s4;
  static const double _badgeShadowOpacity = 0.25;
  static const double _trackPadding = AppSizes.s2;

  final FlowScoreDay day;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fillHeight = trackHeight * (day.percent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: trackHeight,
          padding: const EdgeInsets.all(_trackPadding),
          alignment: Alignment.bottomCenter,
          decoration: AppShapes.decoration(
            color: colors.borderSubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: day.hasScore
              ? _FlowScoreBarFill(
                  height: fillHeight,
                  badge: _FlowScoreBadge(
                    label: '${day.percent}%',
                    height: _badgeHeight,
                    borderWidth: _badgeBorderWidth,
                    shadowBlur: _badgeShadowBlur,
                    shadowOpacity: _badgeShadowOpacity,
                  ),
                  badgeOverlap: _badgeOverlap,
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          day.label,
          style: AppTypography.captionMediumSmall.copyWith(
            color: colors.textFaint,
          ),
        ),
      ],
    );
  }
}

class _FlowScoreBarFill extends StatelessWidget {
  const _FlowScoreBarFill({
    required this.height,
    required this.badge,
    required this.badgeOverlap,
  });

  final double height;
  final Widget badge;
  final double badgeOverlap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: AppShapes.decoration(
                gradient: context.gradients.barFill,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
          ),
          Positioned(top: -badgeOverlap, child: badge),
        ],
      ),
    );
  }
}

class _FlowScoreBadge extends StatelessWidget {
  const _FlowScoreBadge({
    required this.label,
    required this.height,
    required this.borderWidth,
    required this.shadowBlur,
    required this.shadowOpacity,
  });

  final String label;
  final double height;
  final double borderWidth;
  final double shadowBlur;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: AppShapes.decoration(
        color: colors.primaryDeep,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.textPrimary, width: borderWidth),
        shadows: [
          BoxShadow(
            color: colors.backgroundPrimary.withValues(alpha: shadowOpacity),
            offset: const Offset(0, AppSizes.s2),
            blurRadius: shadowBlur,
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.captionMedium.copyWith(
          color: colors.backgroundSecondary,
        ),
      ),
    );
  }
}
