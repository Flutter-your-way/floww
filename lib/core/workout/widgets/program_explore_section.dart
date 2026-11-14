import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/workout/models/workout_discipline.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/challenge_board_section.dart';
import 'package:floww/core/workout/widgets/create_program_card.dart';
import 'package:floww/core/workout/widgets/indexed_content_switcher.dart';
import 'package:floww/core/workout/widgets/program_collection_card.dart';
import 'package:floww/core/workout/widgets/program_discipline_switcher.dart';
import 'package:floww/core/workout/widgets/program_goal_carousel.dart';
import 'package:floww/core/workout/widgets/program_level_tile.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';
import 'package:floww/core/workout/widgets/program_section_heading.dart';

class ProgramExploreSection extends StatelessWidget {
  const ProgramExploreSection({
    super.key,
    required this.heading,
    required this.disciplines,
    required this.onSelectDiscipline,
    required this.goals,
    required this.levels,
    required this.onSelectGoal,
    required this.onSelectLevel,
    required this.onOpenProgram,
    this.skills = const [],
    this.challenges,
    this.isPremiumUnlocked = true,
    this.collection,
    this.onOpenCollection,
    this.onCreate,
  });

  final String heading;
  final List<ProgramFilterItem<WorkoutDiscipline>> disciplines;
  final ValueChanged<WorkoutDiscipline> onSelectDiscipline;
  final List<ProgramGoalCardItem> goals;
  final List<ProgramLevelCardItem> levels;
  final ValueChanged<String> onSelectGoal;
  final ValueChanged<ProgramLevelCardItem> onSelectLevel;
  final ValueChanged<String> onOpenProgram;
  final List<ProgramItem> skills;
  final ChallengeBoardItem? challenges;
  final bool isPremiumUnlocked;
  final ProgramCollectionItem? collection;
  final VoidCallback? onOpenCollection;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final collection = this.collection;
    final challenges = this.challenges;
    final selectedIndex = disciplines.indexWhere((item) => item.isSelected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgramSectionHeading(label: heading),
        SizedBox(height: AppSpacing.lg),
        ProgramDisciplineSwitcher(
          disciplines: disciplines,
          onSelect: onSelectDiscipline,
        ),
        IndexedContentSwitcher(
          index: selectedIndex,
          child: KeyedSubtree(
            key: ValueKey(selectedIndex),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (goals.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xl4),
                  const ProgramSectionHeading(label: 'Choose your goal'),
                  SizedBox(height: AppSpacing.lg),
                  AppPopReveal(
                    appearOnMount: true,
                    child: ProgramGoalCarousel(
                      goals: goals,
                      onSelect: (goal) {
                        HapticManager.light();
                        onSelectGoal(goal.id);
                      },
                    ),
                  ),
                ],
                if (levels.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xl4),
                  const ProgramSectionHeading(label: 'Choose your level'),
                  SizedBox(height: AppSpacing.lg),
                  _LevelGrid(
                    levels: levels,
                    onSelect: (level) {
                      HapticManager.light();
                      onSelectLevel(level);
                    },
                  ),
                ],
                if (skills.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xl4),
                  const ProgramSectionHeading(label: 'Learn a skill'),
                  SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < skills.length; i++) ...[
                    if (i > 0) SizedBox(height: AppSpacing.lg),
                    ProgramRowCard(
                      program: skills[i],
                      isLocked: skills[i].isPremium && !isPremiumUnlocked,
                      onTap: () {
                        HapticManager.light();
                        onOpenProgram(skills[i].id);
                      },
                    ),
                  ],
                ],
                if (challenges != null) ...[
                  SizedBox(height: AppSpacing.xl4),
                  ChallengeBoardSection(
                    board: challenges,
                    onOpen: onOpenProgram,
                  ),
                ],
                if (collection != null || onCreate != null) ...[
                  SizedBox(height: AppSpacing.xl4),
                  const ProgramSectionHeading(label: 'Make it yours'),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (collection != null) ...[
                  ProgramCollectionCard(
                    collection: collection,
                    onTap: onOpenCollection,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (onCreate != null) CreateProgramCard(onTap: onCreate),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.levels, required this.onSelect});

  static const int _columns = 2;
  static const double _tileAspectRatio = 1.6;

  final List<ProgramLevelCardItem> levels;
  final ValueChanged<ProgramLevelCardItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row * _columns < levels.length; row++) ...[
          if (row > 0) SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var column = 0; column < _columns; column++) ...[
                if (column > 0) SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _tileAspectRatio,
                    child: row * _columns + column < levels.length
                        ? ProgramLevelTile(
                            level: levels[row * _columns + column],
                            onTap: () =>
                                onSelect(levels[row * _columns + column]),
                          )
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
