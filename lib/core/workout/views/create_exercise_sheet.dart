import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/text_field/compact_text_field.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';

class CreateExerciseSheet extends StatelessWidget {
  const CreateExerciseSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required ExerciseLibraryViewModel viewModel,
  }) {
    viewModel.resetDraft();
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const CreateExerciseSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseLibraryViewModel>(
      builder: (context, viewModel, child) {
        return AppFloatingSheet(
          child: AppSheetPanel(
            title: 'Create Exercise',
            subtitle: 'Add a custom exercise to your library',
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(label: 'Exercise Name'),
                SizedBox(height: AppSpacing.md),
                CompactTextField(
                  hintText: 'e.g. Cable Fly, Bulgarian Split Squat...',
                  textCapitalization: TextCapitalization.words,
                  onChanged: viewModel.updateDraftName,
                ),
                SizedBox(height: AppSpacing.xl),
                const SectionLabel(label: 'Muscle Group'),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final group in viewModel.muscleGroups)
                      SelectableChip(
                        label: group.label,
                        isSelected: group == viewModel.draftGroup,
                        onTap: () => viewModel.selectDraftGroup(group),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                const SectionLabel(label: 'Equipment'),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final equipment in viewModel.equipmentOptions)
                      SelectableChip(
                        label: equipment.label,
                        isSelected: equipment == viewModel.draftEquipment,
                        onTap: () => viewModel.selectDraftEquipment(equipment),
                      ),
                  ],
                ),
              ],
            ),
            footer: Align(
              child: IntrinsicWidth(
                child: PillButton(
                  label: 'Add to Library',
                  icon: Icons.add,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                  onPressed: viewModel.canSaveDraft
                      ? () {
                          viewModel.saveDraft();
                          Navigator.of(context).maybePop();
                        }
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
