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
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/view_models/add_exercise_view_model.dart';
import 'package:floww/core/workout/widgets/exercise_picker_row.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

typedef AddExerciseCallback =
    void Function(String sectionId, WorkoutEntryEntity exercise);

class AddExerciseSheet extends StatelessWidget {
  const AddExerciseSheet({super.key, required this.onAdd});

  static const double _pickerMaxHeight = AppSizes.s160 + AppSizes.s64;

  final AddExerciseCallback onAdd;

  static Future<void> show({
    required BuildContext context,
    required List<AddExerciseSectionOption> sections,
    required AddExerciseCallback onAdd,
    String? initialSectionId,
    String? submitLabel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AddExerciseViewModel(
          service: WorkoutCatalogService(),
          sections: sections,
          initialSectionId: initialSectionId,
          submitLabel: submitLabel ?? 'Add to Workout',
        )..load(),
        child: AddExerciseSheet(onAdd: onAdd),
      ),
    );
  }

  void _submit(BuildContext context, AddExerciseViewModel viewModel) {
    final exercise = viewModel.buildExercise();
    if (exercise == null) return;
    HapticManager.success();
    onAdd(viewModel.selectedSectionId, exercise);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddExerciseViewModel>(
      builder: (context, viewModel, child) {
        final results = viewModel.results;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(label: viewModel.sectionLabel),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final section in viewModel.sections)
                      SelectableChip(
                        label: section.label,
                        isSelected: section.id == viewModel.selectedSectionId,
                        onTap: () => viewModel.selectSection(section.id),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                SectionLabel(label: viewModel.exerciseLabel),
                SizedBox(height: AppSpacing.md),
                CompactTextField(
                  hintText: viewModel.searchHint,
                  icon: Icons.search_rounded,
                  onChanged: viewModel.search,
                ),
                SizedBox(height: AppSpacing.md),
                if (results.isEmpty)
                  _EmptyResults(message: viewModel.emptyResultsMessage)
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: _pickerMaxHeight,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < results.length; i++) ...[
                            if (i > 0) SizedBox(height: AppSpacing.sm),
                            ExercisePickerRow(
                              exercise: results[i],
                              onTap: () {
                                HapticManager.selection();
                                viewModel.selectExercise(results[i].id);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: AppSpacing.xl),
                SectionLabel(label: viewModel.targetsLabel),
                SizedBox(height: AppSpacing.md),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ValueStepper(
                          target: viewModel.setsTarget,
                          onAdjust: viewModel.adjustSets,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ValueStepper(
                          target: viewModel.repsTarget,
                          onAdjust: viewModel.adjustReps,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ValueStepper(
                          target: viewModel.restTarget,
                          onAdjust: viewModel.adjustRest,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ValueStepper(
                        target: viewModel.weightTarget,
                        onAdjust: viewModel.isBodyweight
                            ? null
                            : viewModel.adjustWeight,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    SelectableChip(
                      label: viewModel.bodyweightLabel,
                      isSelected: viewModel.isBodyweight,
                      onTap: () {
                        HapticManager.selection();
                        viewModel.toggleBodyweight();
                      },
                    ),
                  ],
                ),
              ],
            ),
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  viewModel.summaryLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyXSmallMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                PillButton(
                  label: viewModel.submitLabel,
                  icon: Icons.add,
                  onPressed: viewModel.canSubmit
                      ? () => _submit(context, viewModel)
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmallRegularTight.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
