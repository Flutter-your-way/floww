import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/create_program_card.dart';
import 'package:floww/core/workout/widgets/program_collection_card.dart';
import 'package:floww/core/workout/widgets/program_goal_carousel.dart';
import 'package:floww/core/workout/widgets/program_level_tile.dart';

class ProgramExploreSection extends StatelessWidget {
  const ProgramExploreSection({
    super.key,
    required this.goals,
    required this.levels,
    required this.onSelectGoal,
    required this.onSelectLevel,
    this.collection,
    this.onOpenCollection,
    this.onCreate,
  });

  final List<ProgramGoalCardItem> goals;
  final List<ProgramLevelCardItem> levels;
  final ValueChanged<String> onSelectGoal;
  final ValueChanged<ProgramLevel> onSelectLevel;
  final ProgramCollectionItem? collection;
  final VoidCallback? onOpenCollection;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final collection = this.collection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ExploreHeading(label: 'Choose your goal'),
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
        if (levels.isNotEmpty) ...[
          SizedBox(height: AppSpacing.xl4),
          const _ExploreHeading(label: 'Choose your level'),
          SizedBox(height: AppSpacing.lg),
          _LevelGrid(
            levels: levels,
            onSelect: (level) {
              HapticManager.light();
              onSelectLevel(level);
            },
          ),
        ],
        if (collection != null || onCreate != null) ...[
          SizedBox(height: AppSpacing.xl4),
          const _ExploreHeading(label: 'Make it yours'),
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
    );
  }
}

class _ExploreHeading extends StatelessWidget {
  const _ExploreHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.bodyLargeRegular.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.levels, required this.onSelect});

  static const int _columns = 2;
  static const double _tileAspectRatio = 1.6;

  final List<ProgramLevelCardItem> levels;
  final ValueChanged<ProgramLevel> onSelect;

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
                            onTap: () => onSelect(
                              levels[row * _columns + column].level,
                            ),
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
