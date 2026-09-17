import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/home/models/home_view_data.dart';

class FlowScoreComponentTile extends StatelessWidget {
  const FlowScoreComponentTile({super.key, required this.component});

  final FlowScoreComponent component;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(component.emoji, style: context.textTheme.bodyLarge),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(component.title, style: context.textTheme.titleLarge),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${component.points}',
                  style: context.textTheme.headlineSmall,
                ),
                Text(
                  '/${component.maxPoints}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          component.detail,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppProgressBar(
          progress: component.fraction,
          height: AppSizes.s8,
          color: context.colors.primary,
          trackColor: context.colors.backgroundElevated,
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _PointsPill(
              points: component.hintPoints,
              muted: component.isComplete,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                component.hint,
                textAlign: TextAlign.end,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points, required this.muted});

  final int points;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = muted ? colors.textSecondary : colors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: AppShapes.decoration(
        color: muted ? colors.backgroundSurface : colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: muted ? colors.borderSubtle : colors.borderGlow,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: AppSizes.s14, color: foreground),
          SizedBox(width: AppSpacing.xs),
          Text(
            '+ $points points available',
            style: context.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
