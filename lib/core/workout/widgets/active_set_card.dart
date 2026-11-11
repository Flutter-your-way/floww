import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_card_pop.dart';
import 'package:floww/config/widgets/animations/rolling_text.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/images/exercise_video_surface.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/widgets/active_metric_pill.dart';

class ActiveSetCard extends StatelessWidget {
  const ActiveSetCard({
    super.key,
    required this.exercise,
    required this.setLabel,
    required this.clockLabel,
    required this.isPaused,
    required this.onOptions,
  });

  static const double _videoAspectRatio = 4 / 5;

  final ActiveExerciseItem exercise;
  final String setLabel;
  final String clockLabel;
  final bool isPaused;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCardPop(
      child: AppCard(
        variant: AppCardVariant.sunken,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: _videoAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExerciseVideoSurface(
                      imageUrl: exercise.imageUrl,
                      video: exercise.video,
                      isLoading: exercise.isVideoLoading,
                      fallbackIcon: Icons.fitness_center,
                      fallbackIconSize: AppSizes.s64,
                    ),
                    Positioned(
                      top: AppSpacing.lg,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: _SetStatusPill(
                              setLabel: setLabel,
                              isPaused: isPaused,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          CircularHeaderButton(
                            icon: Icons.more_horiz_rounded,
                            iconColor: colors.textPrimary,
                            backgroundColor: colors.scrim,
                            borderColor: colors.borderMedium,
                            onPressed: onOptions,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _ActiveSetPanel(
                  exercise: exercise,
                  clockLabel: clockLabel,
                  isPaused: isPaused,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSetPanel extends StatelessWidget {
  const _ActiveSetPanel({
    required this.exercise,
    required this.clockLabel,
    required this.isPaused,
  });

  final ActiveExerciseItem exercise;
  final String clockLabel;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading4SemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ActiveMetricPill(
                value: exercise.targetValue,
                label: exercise.targetLabel,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: isPaused ? AppMotion.pausedOpacity : 1,
              duration: AppMotion.expand,
              curve: AppMotion.expandCurve,
              child: RollingText(
                text: clockLabel,
                style: AppTypography.heading1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              'time in set',
              style: AppTypography.bodySmallMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SetStatusPill extends StatelessWidget {
  const _SetStatusPill({required this.setLabel, required this.isPaused});

  final String setLabel;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.scrim,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isPaused ? colors.borderMedium : colors.borderGlow,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LiveDot(isPaused: isPaused),
          SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              '${setLabel.toUpperCase()} · '
              '${isPaused ? 'PAUSED' : 'IN PROGRESS'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmallSemiBold.copyWith(
                color: isPaused ? colors.textSecondary : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.isPaused});

  final bool isPaused;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 900);
  static const double _minOpacity = 0.25;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _LiveDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) _sync();
  }

  void _sync() {
    if (widget.isPaused) {
      _controller.value = 1;
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FadeTransition(
      opacity: Tween<double>(begin: _minOpacity, end: 1).animate(_controller),
      child: Container(
        width: AppSizes.s10,
        height: AppSizes.s10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isPaused ? colors.textSecondary : colors.primary,
        ),
      ),
    );
  }
}
