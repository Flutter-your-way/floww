import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Create Exercise',
                              style: context.textTheme.displaySmall,
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Add a custom exercise to your library',
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
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  const _FieldLabel(label: 'Exercise Name'),
                  SizedBox(height: AppSpacing.lg),
                  _ExerciseNameField(onChanged: viewModel.updateDraftName),
                  SizedBox(height: AppSpacing.xl2),
                  const _FieldLabel(label: 'Muscle Group'),
                  SizedBox(height: AppSpacing.lg),
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
                  SizedBox(height: AppSpacing.xl2),
                  const _FieldLabel(label: 'Equipment'),
                  SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final equipment in viewModel.equipmentOptions)
                        SelectableChip(
                          label: equipment.label,
                          isSelected: equipment == viewModel.draftEquipment,
                          onTap: () =>
                              viewModel.selectDraftEquipment(equipment),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  Align(
                    child: IntrinsicWidth(
                      child: PillButton(
                        label: 'Add to Library',
                        icon: Icons.add,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl3,
                        ),
                        onPressed: viewModel.canSaveDraft
                            ? () {
                                viewModel.saveDraft();
                                Navigator.of(context).maybePop();
                              }
                            : null,
                      ),
                    ),
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

class _ExerciseNameField extends StatelessWidget {
  const _ExerciseNameField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: TextField(
        onChanged: onChanged,
        autofocus: false,
        style: context.textTheme.bodyLarge,
        cursorColor: colors.primary,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'e.g. Cable Fly, Bulgarian Split Squat...',
          hintStyle: context.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
