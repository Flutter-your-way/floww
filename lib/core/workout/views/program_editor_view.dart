import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/workout/view_models/program_editor_view_model.dart';
import 'package:floww/core/workout/views/add_exercise_sheet.dart';
import 'package:floww/core/workout/views/program_exercise_sheet.dart';
import 'package:floww/core/workout/widgets/program_editor_day_card.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProgramEditorView extends StatelessWidget {
  const ProgramEditorView({super.key});

  void _addExercise(
    BuildContext context,
    ProgramEditorViewModel viewModel,
    int weekday,
  ) {
    HapticManager.light();
    AddExerciseSheet.show(
      context: context,
      sections: viewModel.sections,
      initialSectionId: viewModel.defaultSectionId,
      submitLabel: 'Add to Program',
      onAdd: (sectionId, exercise) =>
          viewModel.addExercise(weekday, sectionId, exercise),
    );
  }

  void _editExercise(
    BuildContext context,
    ProgramEditorViewModel viewModel,
    int weekday,
    int index,
  ) {
    HapticManager.light();
    ProgramExerciseSheet.show(
      context: context,
      viewModel: viewModel,
      weekday: weekday,
      index: index,
    );
  }

  Future<void> _save(ProgramEditorViewModel viewModel) async {
    HapticManager.medium();
    final id = await viewModel.save();
    if (id == null) return;
    HapticManager.success();
    NavigationService.instance.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramEditorViewModel>(
      builder: (context, viewModel, child) {
        final colors = context.colors;
        final errorMessage = viewModel.errorMessage;
        final validation = viewModel.validationMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          footer: viewModel.isLoading
              ? null
              : PillButton(
                  label: viewModel.saveLabel,
                  icon: Icons.check_rounded,
                  isLoading: viewModel.isSaving,
                  onPressed: viewModel.canSave ? () => _save(viewModel) : null,
                ),
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else ...[
              if (errorMessage != null) ...[
                AppErrorCard(message: errorMessage, onRetry: viewModel.load),
                SizedBox(height: AppSpacing.xl2),
              ],
              SectionLabel(label: viewModel.nameLabel),
              SizedBox(height: AppSpacing.md),
              CompactTextField(
                hintText: viewModel.nameHint,
                initialText: viewModel.name,
                textCapitalization: TextCapitalization.words,
                onChanged: viewModel.setName,
              ),
              SizedBox(height: AppSpacing.xl2),
              SectionLabel(label: viewModel.goalLabel),
              SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final option in viewModel.goalOptions)
                    SelectableChip(
                      label: option.label,
                      isSelected: option.isSelected,
                      onTap: () {
                        HapticManager.selection();
                        viewModel.selectGoal(option.value);
                      },
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl2),
              SectionLabel(label: viewModel.levelLabel),
              SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final option in viewModel.levelOptions)
                    WorkoutChip(
                      label: option.label,
                      tone: option.isSelected
                          ? WorkoutChipTone.filled
                          : WorkoutChipTone.muted,
                      onTap: () {
                        HapticManager.selection();
                        viewModel.selectLevel(option.value);
                      },
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl2),
              SectionLabel(label: viewModel.lengthLabel),
              SizedBox(height: AppSpacing.md),
              ValueStepper(
                target: viewModel.weeksTarget,
                onAdjust: viewModel.adjustWeeks,
              ),
              SizedBox(height: AppSpacing.xl2),
              Row(
                children: [
                  Expanded(child: SectionLabel(label: viewModel.daysLabel)),
                  Text(
                    viewModel.daysHint,
                    style: AppTypography.labelSmallMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              WeekdayPicker(
                items: viewModel.weekdayItems,
                onToggle: viewModel.toggleWeekday,
              ),
              for (final day in viewModel.days) ...[
                SizedBox(height: AppSpacing.lg),
                ProgramEditorDayCard(
                  key: ValueKey(day.weekday),
                  day: day,
                  nameHint: viewModel.dayNameHint,
                  addLabel: viewModel.addExerciseLabel,
                  onRename: (name) => viewModel.renameDay(day.weekday, name),
                  onEditExercise: (index) =>
                      _editExercise(context, viewModel, day.weekday, index),
                  onAddExercise: () =>
                      _addExercise(context, viewModel, day.weekday),
                ),
              ],
              if (validation != null) ...[
                SizedBox(height: AppSpacing.xl),
                Text(
                  validation,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.accentOrange,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
