import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/widgets/animations/animated_value_text.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

import '../models/goal_pace.dart';
import 'custom_progress_widget.dart';
import 'goal_projection_chart.dart';

class GoalPacePanel extends StatelessWidget {
  const GoalPacePanel({
    super.key,
    required this.projection,
    required this.onPaceChanged,
  });

  final GoalPaceProjection projection;
  final ValueChanged<double> onPaceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoalPaceRateCard(projection: projection, onPaceChanged: onPaceChanged),
        SizedBox(height: AppSpacing.lg),
        GoalProjectionCard(projection: projection),
      ],
    );
  }
}

class GoalPaceRateCard extends StatelessWidget {
  const GoalPaceRateCard({
    super.key,
    required this.projection,
    required this.onPaceChanged,
  });

  final GoalPaceProjection projection;
  final ValueChanged<double> onPaceChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final config = projection.config;

    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(config.icon, size: AppSizes.s20, color: colors.primary),
              SizedBox(width: AppSpacing.md),
              Text(
                config.label,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${GoalPaceConfig.horizonWeeks} wk outlook',
                style: AppTypography.bodySmallMedium.copyWith(
                  color: colors.textQuiet,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedValueText(
                value: projection.paceLabel,
                duration: AppMotion.press,
                alignment: Alignment.centerRight,
                style: AppTypography.heading2Bold.copyWith(
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                config.unit,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textQuiet,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl2),
          CustomPillSlider(
            value: projection.pace,
            min: config.min,
            max: config.max,
            onChanged: onPaceChanged,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                'Difficulty',
                style: AppTypography.bodySmallMedium.copyWith(
                  color: colors.textQuiet,
                ),
              ),
              const Spacer(),
              GoalDifficultyBadge(difficulty: projection.difficulty),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AnimatedValueText(
            value: projection.difficulty.hint,
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalDifficultyBadge extends StatelessWidget {
  const GoalDifficultyBadge({super.key, required this.difficulty});

  final GoalPaceDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = switch (difficulty) {
      GoalPaceDifficulty.easy => colors.success,
      GoalPaceDifficulty.moderate => colors.warning,
      GoalPaceDifficulty.hard => colors.accentOrange,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: AppMotion.expand,
          width: AppSizes.s8,
          height: AppSizes.s8,
          decoration: AppShapes.decoration(
            color: tone,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        AnimatedDefaultTextStyle(
          duration: AppMotion.expand,
          style: AppTypography.bodySmallSemiBold.copyWith(color: tone),
          child: Text(difficulty.label),
        ),
      ],
    );
  }
}

class GoalProjectionCard extends StatelessWidget {
  const GoalProjectionCard({super.key, required this.projection});

  final GoalPaceProjection projection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = projection.targetDate;
    final headlineStyle = AppTypography.heading4Medium.copyWith(
      color: colors.textQuiet,
    );

    return AppCard(
      variant: AppCardVariant.innerGlow,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: headlineStyle,
              children: [
                TextSpan(text: projection.headlineLead),
                TextSpan(
                  text: projection.headlineValue,
                  style: AppTypography.heading4SemiBold.copyWith(
                    color: colors.primary,
                  ),
                ),
                TextSpan(text: projection.headlineTail),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoalDatePill(label: date.day.toString()),
              SizedBox(width: AppSpacing.md),
              GoalDatePill(label: AppDateUtils.monthName(date)),
              SizedBox(width: AppSpacing.md),
              GoalDatePill(label: date.year.toString()),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            projection.config.outcome,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: colors.textQuiet,
            ),
          ),
          SizedBox(height: AppSpacing.xl3),
          GoalProjectionChart(
            frame: GoalChartFrame(
              samples: projection.samples,
              axisMin: projection.axisMin,
              axisMax: projection.axisMax,
              bandMin: projection.bandMin,
              bandMax: projection.bandMax,
            ),
            startLabel: projection.startLabel,
            endLabel: projection.endLabel,
            startCaption: 'Today',
            endCaption: AppDateUtils.monthYear(date),
          ),
        ],
      ),
    );
  }
}

class GoalDatePill extends StatelessWidget {
  const GoalDatePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXLargeBold.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
