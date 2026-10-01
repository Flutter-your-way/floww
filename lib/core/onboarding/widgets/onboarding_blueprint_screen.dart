import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_orb_palette.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/config/widgets/animations/staggered_reveal_mixin.dart';
import 'package:floww/config/widgets/animations/step_reveal_item.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/effects/animated_orb.dart';

import '../models/onboarding_analysis.dart';

const double _orbBoxSize = AppSizes.s100 * 2;
const double _orbSize = _orbBoxSize * 1.6;
const double _mlPerLiter = 1000;

class OnboardingBlueprintScreen extends StatefulWidget {
  const OnboardingBlueprintScreen({
    super.key,
    required this.title,
    required this.analysis,
    required this.onEnter,
    this.isSubmitting = false,
    this.error,
  });

  final String title;
  final OnboardingAnalysis analysis;
  final VoidCallback onEnter;
  final bool isSubmitting;
  final String? error;

  @override
  State<OnboardingBlueprintScreen> createState() =>
      _OnboardingBlueprintScreenState();
}

class _OnboardingBlueprintScreenState extends State<OnboardingBlueprintScreen>
    with SingleTickerProviderStateMixin, StaggeredRevealMixin {
  @override
  int get revealCount => 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final analysis = widget.analysis;
    final targets = analysis.targets;
    final error = widget.error;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradientTokens.blueprintBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      StepRevealItem(
                        presence: presence(0),
                        child: Text(
                          'YOUR FLOWW BLUEPRINT',
                          style: AppTypography.labelLargeSemiBold.copyWith(
                            color: colors.textSubtle,
                            letterSpacing: AppSizes.s1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StepRevealItem(
                          presence: presence(1),
                          child: const Center(
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
                                    playIntro: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      StepRevealItem(
                        presence: presence(2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: context.textTheme.displayLarge?.copyWith(
                              color: colors.textPrimary,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      StepRevealItem(
                        presence: presence(3),
                        child: Text(
                          analysis.headline.isEmpty
                              ? 'Designed by WAVE just for you'
                              : analysis.headline,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLargeMedium.copyWith(
                            color: colors.textSubtle,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl3),
                      StepRevealItem(
                        presence: presence(4),
                        child: _FlowScoreCard(blueprint: analysis.blueprint),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      StepRevealItem(
                        presence: presence(5),
                        child: _CaloriesCard(targets: targets),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      StepRevealItem(
                        presence: presence(6),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppSpacing.lg,
                            children: [
                              Expanded(
                                child: _GoalTile(
                                  icon: Icons.water_drop_rounded,
                                  title: 'Water Goal',
                                  value: (targets.waterMl / _mlPerLiter)
                                      .toStringAsFixed(1),
                                  unit: 'Liters',
                                ),
                              ),
                              Expanded(
                                child: _GoalTile(
                                  icon: Icons.nightlight_round,
                                  title: 'Sleep Goal',
                                  value: NumberFormatter.trimmed(
                                    analysis.blueprint.sleepHours,
                                  ),
                                  unit: 'Hours',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: StepRevealItem(
                  presence: presence(7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error != null) ...[
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.destructive,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                      ],
                      CustomButton(
                        text: 'Enter Floww',
                        trailingIcon: Icons.arrow_forward_rounded,
                        isLoading: widget.isSubmitting,
                        onPressed: widget.onEnter,
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlueprintTile extends StatelessWidget {
  const _BlueprintTile({required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: AppShapes.decoration(
        color: gradient == null ? colors.backgroundSecondary : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: child,
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({required this.icon, required this.title, this.style});

  final IconData icon;
  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.lg,
      children: [
        Icon(icon, size: AppSizes.s20, color: context.colors.textPrimary),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style ?? context.textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _FlowScoreCard extends StatelessWidget {
  const _FlowScoreCard({required this.blueprint});

  final OnboardingBlueprint blueprint;

  Color _modeColor(AppColorTokens colors) => switch (blueprint.mode) {
    AppThemeMode.flow => colors.success,
    AppThemeMode.steady => AppColorTokens.steady.primary,
    AppThemeMode.restore => AppColorTokens.restore.primary,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _BlueprintTile(
      gradient: context.gradients.glowCard,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: blueprint.flowScore.toDouble()),
        duration: AppMotion.blueprintScore,
        curve: AppMotion.blueprintScoreCurve,
        builder: (context, score, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: _TileHeader(
                    icon: Icons.bolt_rounded,
                    title: 'Readiness',
                  ),
                ),
                Text(
                  '${score.round()}',
                  style: AppTypography.displayNumericSmall.copyWith(
                    fontSize: AppSizes.s40,
                    color: colors.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '%',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            _FlowScoreBar(progress: score / 100),
            if (blueprint.flowScoreReason.isNotEmpty) ...[
              SizedBox(height: AppSpacing.lg),
              Text(
                blueprint.flowScoreReason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      spacing: AppSpacing.xl,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _modeColor(colors),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: AppSizes.s8),
                        ),
                        Expanded(
                          child: _BlueprintStat(
                            label: "TODAY'S MODE",
                            value: blueprint.mode.name.toUpperCase(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    width: AppSpacing.xl4,
                    thickness: AppSizes.s1,
                    color: colors.borderMedium,
                  ),
                  Expanded(
                    child: _BlueprintStat(
                      label: 'WORKOUT SPLIT',
                      value: blueprint.workoutSplit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueprintStat extends StatelessWidget {
  const _BlueprintStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSubtle,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _FlowScoreBar extends StatelessWidget {
  const _FlowScoreBar({required this.progress});

  final double progress;

  static const double _thumbWidth = AppSizes.s8;
  static const double _thumbBorder = AppSizes.s2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = progress.clamp(0.0, 1.0);
    return SizedBox(
      height: AppSizes.s24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final fillWidth = width * fraction;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: AppSizes.s16,
                decoration: AppShapes.decoration(
                  color: colors.borderSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              Container(
                width: fillWidth,
                height: AppSizes.s16,
                decoration: AppShapes.decoration(
                  gradient: AppGradientTokens.flowScoreFill,
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(AppRadius.full),
                    right: fraction >= 1
                        ? const Radius.circular(AppRadius.full)
                        : Radius.zero,
                  ),
                ),
              ),
              if (fraction > 0)
                Positioned(
                  left: (fillWidth - _thumbWidth / 2).clamp(
                    0.0,
                    width - _thumbWidth,
                  ),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: _thumbWidth,
                    decoration: AppShapes.decoration(
                      color: colors.primaryDeep,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      side: BorderSide(
                        color: colors.textPrimary,
                        width: _thumbBorder,
                      ),
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

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.targets});

  final OnboardingTargets targets;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unitStyle = context.textTheme.headlineSmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w400,
    );
    return _BlueprintTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TileHeader(
            icon: Icons.assignment_rounded,
            title: 'Daily Calories',
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: NumberFormatter.grouped(targets.calories),
                          style: AppTypography.displayNumericSmall.copyWith(
                            fontSize: AppSizes.s40,
                            color: colors.primary,
                          ),
                        ),
                        TextSpan(text: '  kcal', style: unitStyle),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    'Protein Target',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.textSubtle,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${targets.proteinG}',
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: colors.accentOrangeLight,
                          ),
                        ),
                        TextSpan(
                          text: ' g/day',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return _BlueprintTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: icon,
            title: title,
            style: AppTypography.heading4SemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: value, style: context.textTheme.displaySmall),
                TextSpan(
                  text: '  $unit',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w400,
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
