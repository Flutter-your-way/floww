import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({super.key, required this.session, this.onTap});

  final WorkoutHistoryItem session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusLabel = session.statusLabel;

    final card = AppCard(
      variant: session.isHighlighted
          ? AppCardVariant.highlighted
          : AppCardVariant.plain,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      session.dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    session.effectLabel,
                    style: AppTypography.bodyXLargeBold.copyWith(
                      color: colors.accentOrange,
                    ),
                  ),
                  Text(
                    'effect',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < session.metrics.length; i++) ...[
                      if (i > 0) SizedBox(width: AppSpacing.xl2),
                      Flexible(
                        child: _HistoryMetric(metric: session.metrics[i]),
                      ),
                    ],
                  ],
                ),
              ),
              if (statusLabel != null) ...[
                SizedBox(width: AppSpacing.lg),
                WorkoutChip(label: statusLabel),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return PressScale(onTap: onTap, child: card);
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.metric});

  final WorkoutMetricItem metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(metric.icon, size: AppSizes.s16, color: colors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
