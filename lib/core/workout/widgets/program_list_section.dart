import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/create_program_card.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ProgramListSection extends StatelessWidget {
  const ProgramListSection({
    super.key,
    required this.programs,
    required this.goalFilters,
    required this.levelFilters,
    required this.countLabel,
    required this.emptyMessage,
    required this.onSelectGoal,
    required this.onSelectLevel,
    this.onOpen,
    this.onCreate,
    this.isPremiumUnlocked = true,
  });

  final List<ProgramItem> programs;
  final List<ProgramFilterItem<String>> goalFilters;
  final List<ProgramFilterItem<ProgramLevel?>> levelFilters;
  final String countLabel;
  final String emptyMessage;
  final ValueChanged<String> onSelectGoal;
  final ValueChanged<ProgramLevel?> onSelectLevel;
  final ValueChanged<ProgramItem>? onOpen;
  final VoidCallback? onCreate;
  final bool isPremiumUnlocked;

  @override
  Widget build(BuildContext context) {
    final onOpen = this.onOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPopReveal(
          appearOnMount: true,
          child: CreateProgramCard(onTap: onCreate),
        ),
        SizedBox(height: AppSpacing.xl3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < goalFilters.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                SelectableChip(
                  label: goalFilters[i].label,
                  isSelected: goalFilters[i].isSelected,
                  onTap: () {
                    HapticManager.selection();
                    onSelectGoal(goalFilters[i].value);
                  },
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < levelFilters.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                WorkoutChip(
                  label: levelFilters[i].label,
                  tone: levelFilters[i].isSelected
                      ? WorkoutChipTone.filled
                      : WorkoutChipTone.muted,
                  onTap: () {
                    HapticManager.selection();
                    onSelectLevel(levelFilters[i].value);
                  },
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl2),
        Align(
          alignment: Alignment.centerLeft,
          child: SectionLabel(
            label: countLabel,
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        if (programs.isEmpty)
          Text(
            emptyMessage,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        for (var i = 0; i < programs.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          AppPopReveal(
            key: ValueKey(programs[i].id),
            appearOnMount: true,
            child: ProgramRowCard(
              program: programs[i],
              isLocked:
                  programs[i].isPremium &&
                  !programs[i].isActive &&
                  !isPremiumUnlocked,
              onTap: onOpen == null ? null : () => onOpen(programs[i]),
            ),
          ),
        ],
      ],
    );
  }
}
