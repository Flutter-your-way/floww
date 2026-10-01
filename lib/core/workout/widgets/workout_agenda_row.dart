import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';

class WorkoutAgendaRow extends StatelessWidget {
  const WorkoutAgendaRow({
    super.key,
    required this.entry,
    this.onAction,
    this.onRemove,
  });

  final WorkoutAgendaEntryItem entry;
  final VoidCallback? onAction;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionLabel = entry.actionLabel;
    final isCompleted = entry.status == WorkoutAgendaStatus.completed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: entry.isFocused ? colors.tint : colors.borderSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: entry.isFocused
              ? colors.borderGlow
              : colors.surfaceTranslucent,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        children: [
          WorkoutIconTile(
            imageUrl: entry.imageUrl,
            icon: entry.isCatchUp
                ? Icons.event_repeat_rounded
                : Icons.fitness_center,
            isHighlighted: entry.isFocused,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  entry.metaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    WorkoutChip(
                      label: entry.tagLabel,
                      tone: entry.isCatchUp
                          ? WorkoutChipTone.accent
                          : WorkoutChipTone.muted,
                    ),
                    WorkoutChip(
                      label: entry.statusLabel,
                      icon: isCompleted ? Icons.check_rounded : null,
                      tone: isCompleted
                          ? WorkoutChipTone.filled
                          : entry.status == WorkoutAgendaStatus.inProgress
                          ? WorkoutChipTone.accent
                          : WorkoutChipTone.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(width: AppSpacing.md),
            PillButton(
              variant: entry.action == WorkoutAgendaAction.focus
                  ? PillButtonVariant.outline
                  : PillButtonVariant.primary,
              height: AppSizes.s36,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              label: actionLabel,
              onPressed: onAction,
            ),
          ],
          if (entry.canRemove && onRemove != null) ...[
            SizedBox(width: AppSpacing.xs),
            PressScale(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: AppSizes.s20,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
