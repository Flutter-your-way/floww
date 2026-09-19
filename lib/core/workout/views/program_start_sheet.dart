import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class ProgramStartSheet extends StatelessWidget {
  const ProgramStartSheet({super.key, required this.detail, this.onStart});

  static Future<void> show({
    required BuildContext context,
    required ProgramDetailItem detail,
    VoidCallback? onStart,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ProgramStartSheet(detail: detail, onStart: onStart),
    );
  }

  final ProgramDetailItem detail;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final warning = detail.warning;

    return AppFloatingSheet(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.s56,
                  height: AppSizes.s56,
                  alignment: Alignment.center,
                  decoration: AppShapes.decoration(
                    color: colors.bgTinted,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    side: BorderSide(
                      color: colors.borderGlow,
                      width: AppSizes.s1,
                    ),
                  ),
                  child: Icon(
                    Icons.bolt,
                    size: AppSizes.s28,
                    color: colors.primaryAlt,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        detail.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        detail.description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                CircularHeaderButton(
                  icon: Icons.close_rounded,
                  size: AppSizes.s36,
                  iconSize: AppSizes.s20,
                  backgroundColor: colors.backgroundPrimary,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl2),
            _ProgramStatsBox(stats: detail.stats),
            if (warning != null) ...[
              SizedBox(height: AppSpacing.lg),
              _ProgramWarningBox(message: warning),
            ],
            SizedBox(height: AppSpacing.xl2),
            Align(
              child: IntrinsicWidth(
                child: PillButton(
                  label: detail.startLabel,
                  icon: Icons.play_arrow_rounded,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                  onPressed: onStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramStatsBox extends StatelessWidget {
  const _ProgramStatsBox({required this.stats});

  final List<WorkoutStatItem> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) ...[
              SizedBox(width: AppSpacing.lg),
              Container(
                width: AppSizes.s1,
                height: AppSizes.s44,
                color: colors.borderMedium,
              ),
              SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: WorkoutStatTile(
                stat: stats[i],
                titleStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgramWarningBox extends StatelessWidget {
  const _ProgramWarningBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.accentOrange, width: AppSizes.s1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: AppSizes.s16,
            color: colors.accentOrangeLight,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
