import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class ProgramDetailSheet extends StatelessWidget {
  const ProgramDetailSheet({
    super.key,
    required this.detail,
    this.onStart,
    this.onCustomize,
    this.onDelete,
    this.onStop,
  });

  static Future<void> show({
    required BuildContext context,
    required ProgramDetailItem detail,
    VoidCallback? onStart,
    VoidCallback? onCustomize,
    VoidCallback? onDelete,
    VoidCallback? onStop,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ProgramDetailSheet(
        detail: detail,
        onStart: onStart,
        onCustomize: onCustomize,
        onDelete: onDelete,
        onStop: onStop,
      ),
    );
  }

  final ProgramDetailItem detail;
  final VoidCallback? onStart;
  final VoidCallback? onCustomize;
  final VoidCallback? onDelete;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final warning = detail.warning;
    final onDelete = this.onDelete;
    final onStop = this.onStop;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: detail.name,
        subtitle: detail.description,
        titleStyle: context.textTheme.headlineSmall,
        leading: WorkoutIconTile(icon: detail.icon, isHighlighted: true),
        closeButtonSize: AppSizes.s36,
        closeIconSize: AppSizes.s20,
        onClose: () => Navigator.of(context).maybePop(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProgramStatsBox(stats: detail.stats),
            if (warning != null) ...[
              SizedBox(height: AppSpacing.lg),
              _ProgramWarningBox(message: warning),
            ],
            SizedBox(height: AppSpacing.xl2),
            const SectionLabel(label: 'Weekly schedule'),
            SizedBox(height: AppSpacing.md),
            for (var i = 0; i < detail.schedule.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.md),
              _ScheduleRow(item: detail.schedule[i]),
            ],
          ],
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!detail.isActive)
              PillButton(
                label: 'Start program',
                icon: Icons.play_arrow_rounded,
                onPressed: onStart,
              ),
            if (!detail.isActive) SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    variant: PillButtonVariant.outline,
                    height: AppSizes.s44,
                    label: detail.isCustom ? 'Edit' : 'Customize',
                    icon: Icons.tune_rounded,
                    onPressed: onCustomize,
                  ),
                ),
                if (detail.isActive && onStop != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.outline,
                      height: AppSizes.s44,
                      label: 'Stop',
                      icon: Icons.stop_rounded,
                      labelColor: colors.destructiveBorder,
                      iconColor: colors.destructiveBorder,
                      onPressed: onStop,
                    ),
                  ),
                ],
                if (detail.isCustom && onDelete != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.outline,
                      height: AppSizes.s44,
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      labelColor: colors.destructiveBorder,
                      iconColor: colors.destructiveBorder,
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final ProgramScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s40,
            child: Text(
              item.weekdayLabel,
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.primaryAlt,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
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
