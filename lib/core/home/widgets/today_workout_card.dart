import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_outlined_button.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/home/widgets/home_card_empty_state.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/theme/app_shapes.dart';

class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({
    super.key,
    this.workout,
    this.completed,
    this.onStartWorkout,
    this.onViewSummary,
  });

  final WorkoutRecommendation? workout;
  final CompletedWorkout? completed;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onViewSummary;

  @override
  Widget build(BuildContext context) {
    final workout = this.workout;
    final completed = this.completed;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: "Today's Workout",
            trailing: completed == null
                ? null
                : const AppStatusChip(
                    label: 'COMPLETED',
                    icon: Icons.check,
                    variant: AppStatusChipVariant.outlined,
                  ),
          ),
          SizedBox(height: AppSpacing.xl),
          if (completed != null)
            _CompletedWorkoutBody(
              completed: completed,
              onViewSummary: onViewSummary,
            )
          else if (workout == null)
            HomeCardEmptyState(
              icon: Icons.directions_run,
              message: 'No workout planned yet. Start your first session now.',
              buttonText: 'START WORKOUT',
              buttonIcon: Icons.play_arrow,
              filled: true,
              onPressed: onStartWorkout,
            )
          else
            _PlannedWorkoutBody(
              workout: workout,
              onStartWorkout: onStartWorkout,
            ),
        ],
      ),
    );
  }
}

class _PlannedWorkoutBody extends StatelessWidget {
  const _PlannedWorkoutBody({required this.workout, this.onStartWorkout});

  final WorkoutRecommendation workout;
  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkoutIdentityRow(
          icon: Icons.fitness_center,
          iconColor: context.colors.textPrimary,
          iconBackground: context.colors.backgroundElevated,
          title: workout.title,
          metrics: [
            _WorkoutMetric(
              icon: Icons.access_time,
              label: workout.durationLabel,
            ),
            _WorkoutMetric(icon: Icons.bolt, label: workout.intensityLabel),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        _WorkoutNoteBox(
          title: 'Recommended by WAVE because:',
          lines: workout.reasons,
        ),
        SizedBox(height: AppSpacing.lg),
        CustomButton(
          text: 'START WORKOUT',
          icon: Icons.play_arrow,
          backgroundColor: context.colors.textPrimary,
          foregroundColor: context.colors.backgroundPrimary,
          onPressed: onStartWorkout,
        ),
      ],
    );
  }
}

class _CompletedWorkoutBody extends StatelessWidget {
  const _CompletedWorkoutBody({required this.completed, this.onViewSummary});

  final CompletedWorkout completed;
  final VoidCallback? onViewSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkoutIdentityRow(
          icon: Icons.check_rounded,
          iconColor: context.colors.primary,
          iconBackground: context.colors.tint,
          iconBorder: context.colors.borderGlow,
          title: completed.title,
          metrics: [
            _WorkoutMetric(
              icon: Icons.check_circle,
              label: completed.completedLabel,
              color: context.colors.primary,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        _WorkoutStatStrip(stats: completed.stats),
        if (completed.highlights.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          _WorkoutNoteBox(
            title: 'Logged by WAVE:',
            lines: completed.highlights,
          ),
        ],
        SizedBox(height: AppSpacing.lg),
        CustomOutlinedButton(
          text: 'VIEW SUMMARY',
          leading: Icon(
            Icons.insights,
            size: AppSizes.s20,
            color: context.colors.textPrimary,
          ),
          onPressed: onViewSummary,
        ),
      ],
    );
  }
}

class _WorkoutMetric {
  const _WorkoutMetric({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;
}

class _WorkoutIdentityRow extends StatelessWidget {
  const _WorkoutIdentityRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.metrics,
    this.iconBorder,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color? iconBorder;
  final String title;
  final List<_WorkoutMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconTile(
          icon: icon,
          size: AppSizes.s40,
          radius: AppRadius.sm,
          backgroundColor: iconBackground,
          borderColor: iconBorder ?? Colors.transparent,
          iconColor: iconColor,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge,
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  for (final metric in metrics) ...[
                    if (metric != metrics.first) SizedBox(width: AppSpacing.lg),
                    Icon(
                      metric.icon,
                      size: AppSizes.s14,
                      color: metric.color ?? context.colors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        metric.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: metric.color ?? context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkoutStatStrip extends StatelessWidget {
  const _WorkoutStatStrip({required this.stats});

  final List<CompletedWorkoutStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        children: [
          for (final stat in stats) ...[
            if (stat != stats.first)
              Container(
                width: AppSizes.s1,
                height: AppSizes.s32,
                color: context.colors.borderSubtle,
              ),
            Expanded(child: _WorkoutStatTile(stat: stat)),
          ],
        ],
      ),
    );
  }
}

class _WorkoutStatTile extends StatelessWidget {
  const _WorkoutStatTile({required this.stat});

  final CompletedWorkoutStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                stat.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              stat.unit,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _WorkoutNoteBox extends StatelessWidget {
  const _WorkoutNoteBox({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: context.colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.colors.borderGlow, width: AppSizes.s1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          for (final line in lines)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: AppSizes.s16,
                    color: context.colors.primary,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(line, style: context.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
