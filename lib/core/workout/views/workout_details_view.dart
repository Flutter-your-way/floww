import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/workout/view_models/workout_details_view_model.dart';
import 'package:floww/core/workout/views/add_exercise_sheet.dart';
import 'package:floww/core/workout/views/edit_notes_sheet.dart';
import 'package:floww/core/workout/widgets/workout_detail_summary_card.dart';
import 'package:floww/core/workout/widgets/workout_empty_state_card.dart';
import 'package:floww/core/workout/widgets/workout_exercises_card.dart';
import 'package:floww/core/workout/widgets/workout_notes_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutDetailsView extends StatelessWidget {
  const WorkoutDetailsView({super.key});

  void _placeholderAction() => HapticManager.light();

  void _openEditNotes(BuildContext context, WorkoutDetailsViewModel viewModel) {
    HapticManager.light();
    EditNotesSheet.show(
      context: context,
      title: viewModel.notesSheetTitle,
      subtitle: viewModel.notesSheetSubtitle,
      hint: viewModel.notesSheetHint,
      submitLabel: viewModel.notesSheetSubmitLabel,
      initialNotes: viewModel.notes,
      onSave: viewModel.updateNotes,
    );
  }

  void _openAddExercise(
    BuildContext context,
    WorkoutDetailsViewModel viewModel,
  ) {
    HapticManager.light();
    AddExerciseSheet.show(
      context: context,
      sections: viewModel.sectionOptions,
      initialSectionId: viewModel.expandedSectionId,
      onAdd: viewModel.addExercise,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutDetailsViewModel>(
      builder: (context, viewModel, child) {
        final detail = viewModel.detail;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          onMore: _placeholderAction,
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else if (viewModel.errorMessage != null)
              AppErrorCard(message: viewModel.errorMessage!)
            else if (detail == null)
              const WorkoutEmptyStateCard(
                icon: Icons.pending_actions,
                title: 'Workout not found',
                message:
                    'This session is no longer available. Pick another one '
                    'from your history.',
              )
            else ...[
              WorkoutDetailSummaryCard(detail: detail),
              SizedBox(height: AppSpacing.lg),
              WorkoutExercisesCard(
                sections: detail.sections,
                countLabel: detail.exerciseCountLabel,
                onToggleSection: viewModel.toggleSection,
                onAddExercise: () => _openAddExercise(context, viewModel),
              ),
              SizedBox(height: AppSpacing.lg),
              TipCard(
                title: detail.insightTitle,
                message: detail.insightMessage,
                icon: Icons.graphic_eq_rounded,
              ),
              SizedBox(height: AppSpacing.lg),
              WorkoutNotesCard(
                notes: detail.notes,
                emptyMessage: viewModel.notesEmptyMessage,
                onEdit: () => _openEditNotes(context, viewModel),
              ),
            ],
          ],
        );
      },
    );
  }
}
