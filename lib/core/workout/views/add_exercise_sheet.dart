import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/workout_detail.dart';
import 'package:floww/core/workout/services/exercise_service.dart';
import 'package:floww/core/workout/view_models/add_exercise_view_model.dart';
import 'package:floww/core/workout/widgets/exercise_picker_row.dart';
import 'package:floww/core/workout/widgets/exercise_search_bar.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

typedef AddExerciseCallback =
    void Function(String sectionId, WorkoutExercise exercise);

class AddExerciseSheet extends StatelessWidget {
  const AddExerciseSheet({super.key, required this.onAdd});

  static const double _pickerMaxHeight = AppSizes.s160 + AppSizes.s64;

  final AddExerciseCallback onAdd;

  static Future<void> show({
    required BuildContext context,
    required List<AddExerciseSectionOption> sections,
    required AddExerciseCallback onAdd,
    String? initialSectionId,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AddExerciseViewModel(
          service: const ExerciseService(),
          sections: sections,
          initialSectionId: initialSectionId,
        ),
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle,
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  _FieldLabel(label: viewModel.sectionLabel),
                  SizedBox(height: AppSpacing.lg),
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
                  SizedBox(height: AppSpacing.xl2),
                  _FieldLabel(label: viewModel.exerciseLabel),
                  SizedBox(height: AppSpacing.lg),
                  ExerciseSearchBar(
                    hint: viewModel.searchHint,
                    onChanged: viewModel.search,
                  ),
                  SizedBox(height: AppSpacing.lg),
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
                              if (i > 0) SizedBox(height: AppSpacing.md),
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
                  SizedBox(height: AppSpacing.xl2),
                  _FieldLabel(label: viewModel.targetsLabel),
                  SizedBox(height: AppSpacing.lg),
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
                  SizedBox(height: AppSpacing.lg),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    viewModel.summaryLabel,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl2),
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
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: context.textTheme.displaySmall),
              SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        CircularHeaderButton(
          icon: Icons.close_rounded,
          size: AppSizes.s40,
          iconSize: AppSizes.s20,
          backgroundColor: context.colors.backgroundPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
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
