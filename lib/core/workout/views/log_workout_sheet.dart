import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/log_workout_view_model.dart';
import 'package:floww/core/workout/views/add_exercise_sheet.dart';
import 'package:floww/core/workout/widgets/logged_exercise_row.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

class LogWorkoutSheet extends StatelessWidget {
  const LogWorkoutSheet({super.key});

  static const double _listMaxHeight = AppSizes.s160 + AppSizes.s64;

  static Future<String?> show({required BuildContext context}) {
    return showAppFloatingSheet<String>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => LogWorkoutViewModel(service: WorkoutSessionService()),
        child: const LogWorkoutSheet(),
      ),
    );
  }

  void _addExercise(BuildContext context, LogWorkoutViewModel viewModel) {
    HapticManager.light();
    AddExerciseSheet.show(
      context: context,
      sections: viewModel.sections,
      submitLabel: viewModel.addExerciseSubmitLabel,
      isLogging: true,
      onAdd: (_, exercise) => viewModel.addExercise(exercise),
    );
  }

  void _removeExercise(LogWorkoutViewModel viewModel, String id) {
    HapticManager.selection();
    viewModel.removeExercise(id);
  }

  Future<void> _save(
    BuildContext context,
    LogWorkoutViewModel viewModel,
  ) async {
    HapticManager.medium();
    final sessionId = await viewModel.save();
    if (sessionId == null || !context.mounted) return;
    HapticManager.success();
    Navigator.of(context).pop(sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final exercises = viewModel.exercises;
        final errorMessage = viewModel.errorMessage;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(label: viewModel.nameLabel),
                SizedBox(height: AppSpacing.md),
                CompactTextField(
                  hintText: viewModel.nameHint,
                  textCapitalization: TextCapitalization.words,
                  onChanged: viewModel.rename,
                ),
                SizedBox(height: AppSpacing.xl),
                SectionLabel(label: viewModel.exercisesLabel),
                SizedBox(height: AppSpacing.md),
                if (exercises.isEmpty)
                  Text(
                    viewModel.emptyExercisesMessage,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: _listMaxHeight,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final exercise in exercises)
                            LoggedExerciseRow(
                              key: ValueKey(exercise.id),
                              exercise: exercise,
                              onRemove: () =>
                                  _removeExercise(viewModel, exercise.id),
                            ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: AppSpacing.lg),
                PillButton(
                  variant: PillButtonVariant.outline,
                  height: AppSizes.s44,
                  label: viewModel.addExerciseLabel,
                  icon: Icons.add_rounded,
                  onPressed: viewModel.isSaving
                      ? null
                      : () => _addExercise(context, viewModel),
                ),
                SizedBox(height: AppSpacing.xl),
                ValueStepper(
                  target: viewModel.durationTarget,
                  onAdjust: viewModel.adjustDuration,
                ),
              ],
            ),
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyXSmallMedium.copyWith(
                      color: context.colors.destructive,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                PillButton(
                  label: viewModel.saveLabel,
                  icon: Icons.check_rounded,
                  isLoading: viewModel.isSaving,
                  onPressed: viewModel.canSave
                      ? () => _save(context, viewModel)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
