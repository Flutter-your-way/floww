import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/program_logo_tile.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ProgramRowCard extends StatelessWidget {
  const ProgramRowCard({
    super.key,
    required this.program,
    this.onTap,
    this.isLocked = false,
  });

  static const String premiumLabel = 'Premium';

  final ProgramItem program;
  final VoidCallback? onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeLabel = program.badgeLabel;

    final card = AppCard(
      variant: program.isActive
          ? AppCardVariant.highlighted
          : AppCardVariant.plain,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgramLogoTile(
                imageUrl: program.logo,
                isHighlighted: program.isActive,
                isWave: program.isWave,
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.heading4SemiBold.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (badgeLabel != null) ...[
                          SizedBox(width: AppSpacing.md),
                          WorkoutChip(
                            label: badgeLabel,
                            tone: program.isActive
                                ? WorkoutChipTone.filled
                                : WorkoutChipTone.accent,
                          ),
                        ],
                        if (isLocked) ...[
                          SizedBox(width: AppSpacing.md),
                          const WorkoutChip(
                            label: premiumLabel,
                            icon: Icons.lock_rounded,
                            tone: WorkoutChipTone.accent,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      program.description,
                      maxLines: 2,
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
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      program.metaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmallMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      program.scheduleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmallMedium.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              for (var i = 0; i < program.weekdays.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.xs),
                _WeekdayDot(item: program.weekdays[i]),
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

class _WeekdayDot extends StatelessWidget {
  const _WeekdayDot({required this.item});

  final ProgramWeekdayItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: AppSizes.s20,
      height: AppSizes.s20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: item.isTraining ? colors.tintStrong : colors.backgroundSurface,
        border: Border.all(
          color: item.isTraining
              ? colors.borderAccent
              : colors.backgroundSurface,
          width: AppSizes.s1,
        ),
      ),
      child: Text(
        item.label,
        style: AppTypography.captionSemiBoldMicro.copyWith(
          color: item.isTraining ? colors.primaryAlt : colors.textDim,
        ),
      ),
    );
  }
}
