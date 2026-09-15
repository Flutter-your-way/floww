import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/views/create_exercise_sheet.dart';
import 'package:floww/core/workout/widgets/exercise_search_bar.dart';
import 'package:floww/core/workout/widgets/muscle_group_card.dart';

class ExerciseLibrarySection extends StatelessWidget {
  const ExerciseLibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseLibraryViewModel>(
      builder: (context, viewModel, child) {
        final groups = viewModel.groups;

        return Column(
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
            if (viewModel.hasCustomExercises) ...[
              SizedBox(height: AppSpacing.xl2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  viewModel.customCountLabel,
                  style: AppTypography.bodyLargeSemiBoldTight.copyWith(
                    color: context.colors.primaryAlt,
                  ),
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl2),
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.lg),
              MuscleGroupCard(
                group: groups[i],
                onToggle: () => viewModel.toggleGroup(groups[i].group),
                onToggleExercise: viewModel.toggleExercise,
              ),
            ],
          ],
        );
      },
    );
  }
}
