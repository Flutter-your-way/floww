import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_card_pop.dart';
import 'package:floww/config/widgets/animations/rolling_text.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
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
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            Row(
              children: [
                _LiveDot(isPaused: isPaused),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${setLabel.toUpperCase()} · '
                    '${isPaused ? 'PAUSED' : 'IN PROGRESS'}',
                    style: AppTypography.labelLargeMedium.copyWith(
                      color: isPaused ? colors.textSecondary : colors.primary,
                    ),
                  ),
                ),
                CircularHeaderButton(
                  icon: Icons.more_horiz_rounded,
                  iconColor: colors.textPrimary,
                  backgroundColor: colors.surfaceTranslucent,
                  borderColor: colors.borderMedium,
                  onPressed: onOptions,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl3),
            Text(
              exercise.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.heading2Bold.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AnimatedOpacity(
              opacity: isPaused ? AppMotion.pausedOpacity : 1,
              duration: AppMotion.expand,
              curve: AppMotion.expandCurve,
              child: RollingText(
                text: clockLabel,
                style: AppTypography.displayNumeric.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              'time in set',
              style: AppTypography.labelLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xl2),
            ActiveMetricPill(
              value: exercise.targetValue,
              label: exercise.targetLabel,
            ),
          ],
        ),
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
