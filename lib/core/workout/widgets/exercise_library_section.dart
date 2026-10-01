import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/images/image_precacher.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/views/create_exercise_sheet.dart';
import 'package:floww/core/workout/views/exercise_detail_sheet.dart';
import 'package:floww/core/workout/widgets/exercise_search_bar.dart';
import 'package:floww/core/workout/widgets/muscle_group_card.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ExerciseLibrarySection extends StatelessWidget {
  const ExerciseLibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseLibraryViewModel>(
      builder: (context, viewModel, child) {
        final groups = viewModel.groups;
        final scopes = viewModel.scopeFilters;
        final equipment = viewModel.equipmentFilters;
        final colors = context.colors;

        return ImagePrecacher(
          urls: viewModel.previewImageUrls,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExerciseSearchBar(
                hint: viewModel.searchHint,
                onChanged: viewModel.search,
                onCreate: () => CreateExerciseSheet.show(
                  context: context,
                  viewModel: viewModel,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                viewModel.hint,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    for (var i = 0; i < scopes.length; i++) ...[
                      if (i > 0) SizedBox(width: AppSpacing.md),
                      SelectableChip(
                        label: scopes[i].label,
                        isSelected: scopes[i].isSelected,
                        onTap: () {
                          HapticManager.selection();
                          viewModel.selectScope(scopes[i].value);
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
                    for (var i = 0; i < equipment.length; i++) ...[
                      if (i > 0) SizedBox(width: AppSpacing.md),
                      WorkoutChip(
                        label: equipment[i].label,
                        tone: equipment[i].isSelected
                            ? WorkoutChipTone.filled
                            : WorkoutChipTone.muted,
                        onTap: () {
                          HapticManager.selection();
                          viewModel.selectEquipment(equipment[i].value);
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
                  label: viewModel.countLabel,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              if (groups.isEmpty && !viewModel.isLoading)
                Text(
                  viewModel.emptyMessage,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              for (var i = 0; i < groups.length; i++) ...[
                if (i > 0) SizedBox(height: AppSpacing.lg),
                AppPopReveal(
                  key: ValueKey(groups[i].group),
                  appearOnMount: true,
                  child: MuscleGroupCard(
                    group: groups[i],
                    onToggle: () => viewModel.toggleGroup(groups[i].group),
                    onOpenExercise: (id) => ExerciseDetailSheet.show(
                      context: context,
                      viewModel: viewModel,
                      exerciseId: id,
                    ),
                    onToggleSaved: (id) {
                      HapticManager.selection();
                      viewModel.toggleSaved(id);
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
