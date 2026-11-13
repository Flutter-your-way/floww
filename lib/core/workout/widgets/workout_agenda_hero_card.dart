import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/core/workout/widgets/workout_hero_photo.dart';

class WorkoutAgendaHeroCard extends StatelessWidget {
  const WorkoutAgendaHeroCard({
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
    final borderRadius = BorderRadius.circular(AppRadius.xl);
    final canRemove = entry.canRemove && onRemove != null;

    return PressScale(
      onTap: entry.action == null ? null : onAction,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: borderRadius,
        ),
        foregroundDecoration: AppShapes.decoration(
          borderRadius: borderRadius,
          side: BorderSide(
            color: entry.isFocused ? colors.borderGlow : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              fit: StackFit.passthrough,
              children: [
                WorkoutHeroPhoto(imageUrl: entry.imageUrl),
                Positioned(
                  top: AppSpacing.lg,
                  left: AppSpacing.lg,
                  child: AppStatusChip(
                    label: entry.tagLabel.toUpperCase(),
                    variant: entry.isCatchUp
                        ? AppStatusChipVariant.outlined
                        : AppStatusChipVariant.solid,
                  ),
                ),
                if (canRemove)
                  Positioned(
                    top: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: _RemoveButton(onTap: onRemove),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl2,
                AppSpacing.xs,
                AppSpacing.xl2,
                AppSpacing.xl,
              ),
              child: _AgendaHeroDetails(entry: entry, onAction: onAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        width: AppSizes.s36,
        height: AppSizes.s36,
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: colors.borderMedium, width: AppSizes.s1),
        ),
        child: Icon(
          Icons.close_rounded,
          size: AppSizes.s20,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class _AgendaHeroDetails extends StatelessWidget {
  const _AgendaHeroDetails({required this.entry, this.onAction});

  final WorkoutAgendaEntryItem entry;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionLabel = entry.actionLabel;
    final isCompleted = entry.status == WorkoutAgendaStatus.completed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.photoCardTitle.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          entry.metaLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMediumRegular.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            WorkoutChip(
              label: entry.statusLabel,
              icon: isCompleted ? Icons.check_rounded : null,
              tone: isCompleted
                  ? WorkoutChipTone.filled
                  : entry.status == WorkoutAgendaStatus.inProgress
                  ? WorkoutChipTone.accent
                  : WorkoutChipTone.muted,
            ),
            const Spacer(),
            if (actionLabel != null)
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
        ),
      ],
    );
  }
}
