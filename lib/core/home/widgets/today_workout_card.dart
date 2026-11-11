import 'package:flutter/material.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/bright_action_button.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/home/widgets/home_card_empty_state.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';

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
    final activeStatus = completed == null
        ? workout?.active?.statusLabel
        : null;

    final card = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: "Today's Workout",
            trailing: completed != null
                ? const AppStatusChip(
                    label: 'COMPLETED',
                    icon: Icons.check,
                    variant: AppStatusChipVariant.outlined,
                  )
                : activeStatus != null
                ? AppStatusChip(
                    label: activeStatus,
                    icon: Icons.timelapse_rounded,
                    variant: AppStatusChipVariant.outlined,
                  )
                : null,
          ),
          SizedBox(height: AppSpacing.xl),
          if (completed != null)
            _CompletedWorkoutBody(
              completed: completed,
              onViewSummary: onViewSummary,
            )
          else if (workout == null)
            HomeCardEmptyState(
              iconAsset: AppImages.runIcon,
              message: 'No workout planned yet. Start your first session now.',
              buttonText: 'START WORKOUT',
              buttonIcon: Icons.play_arrow_rounded,
              onPressed: onStartWorkout,
            )
          else if (workout.active case final active?)
            _ActiveWorkoutBody(
              workout: workout,
              active: active,
              onResume: onStartWorkout,
            )
          else
            _PlannedWorkoutBody(
              workout: workout,
              onStartWorkout: onStartWorkout,
            ),
        ],
      ),
    );

    if (activeStatus == null) return card;
    return GestureDetector(
      onTap: onStartWorkout,
      behavior: HitTestBehavior.opaque,
      child: card,
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
          imageUrl: workout.imageUrl,
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
        BrightActionButton(
          label: 'START WORKOUT',
          icon: Icons.play_arrow_rounded,
          onPressed: onStartWorkout,
        ),
      ],
    );
  }
}

class _ActiveWorkoutBody extends StatelessWidget {
  const _ActiveWorkoutBody({
    required this.workout,
    required this.active,
    this.onResume,
  });

  final WorkoutRecommendation workout;
  final ActiveWorkoutSummary active;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextTitle = active.nextTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkoutIdentityRow(
          icon: Icons.fitness_center,
          iconColor: colors.textPrimary,
          iconBackground: colors.backgroundElevated,
          imageUrl: workout.imageUrl,
          title: workout.title,
          metrics: [
            _WorkoutMetric(
              icon: active.isPaused
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              label: active.positionLabel,
              color: active.isPaused ? colors.textSecondary : colors.primary,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        _ActiveProgressRow(active: active),
        if (nextTitle != null) ...[
          SizedBox(height: AppSpacing.md),
          _UpNextLine(title: nextTitle, detail: active.nextDetail),
        ],
        SizedBox(height: AppSpacing.lg),
        BrightActionButton(
          label: 'RESUME WORKOUT',
          icon: Icons.play_arrow_rounded,
          onPressed: onResume,
        ),
      ],
    );
  }
}

class _ActiveProgressRow extends StatelessWidget {
  const _ActiveProgressRow({required this.active});

  final ActiveWorkoutSummary active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                active.progressLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(
              active.percentLabel,
              style: AppTypography.bodySmallSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(
          progress: active.progress,
          height: AppSizes.s8,
          trackColor: colors.borderSubtle,
          animated: true,
        ),
      ],
    );
  }
}

class _UpNextLine extends StatelessWidget {
  const _UpNextLine({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final detail = this.detail;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
    );

    return Row(
      children: [
        Icon(
          Icons.skip_next_rounded,
          size: AppSizes.s16,
          color: colors.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Up next  ', style: secondary),
                TextSpan(
                  text: title,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (detail != null)
                  TextSpan(text: '  ·  $detail', style: secondary),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
          imageUrl: completed.imageUrl,
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
        PillButton(
          variant: PillButtonVariant.outline,
          width: double.infinity,
          height: AppSizes.s44,
          label: 'VIEW SUMMARY',
          icon: Icons.insights,
          iconColor: context.colors.textPrimary,
          labelStyle: AppTypography.bodyMediumSemiBold,
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
    this.imageUrl,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color? iconBorder;
  final String title;
  final List<_WorkoutMetric> metrics;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          AppPhotoTile(
            url: imageUrl,
            fallbackIcon: icon,
            size: AppSizes.s40,
            radius: AppRadius.sm,
          )
        else
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
          Row(
            children: [
              const WaveAvatarBadge(size: AppSizes.s20, contained: true),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
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
