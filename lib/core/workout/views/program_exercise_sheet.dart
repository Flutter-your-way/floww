import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/program_editor_view_model.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

class ProgramExerciseSheet extends StatelessWidget {
  const ProgramExerciseSheet({
    super.key,
    required this.weekday,
    required this.index,
  });

  static Future<void> show({
    required BuildContext context,
    required ProgramEditorViewModel viewModel,
    required int weekday,
    required int index,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ProgramExerciseSheet(weekday: weekday, index: index),
      ),
    );
  }

  final int weekday;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramEditorViewModel>(
      builder: (context, viewModel, child) {
        final edit = viewModel.exerciseEditFor(weekday, index);
        if (edit == null) return const SizedBox.shrink();
        final colors = context.colors;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: edit.name,
            subtitle: edit.sectionLabel,
            onClose: () => Navigator.of(context).maybePop(),
            body: Row(
              children: [
                Expanded(
                  child: ValueStepper(
                    target: edit.setsTarget,
                    onAdjust: (delta) =>
                        viewModel.adjustSets(weekday, index, delta),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ValueStepper(
                    target: edit.repsTarget,
                    onAdjust: (delta) =>
                        viewModel.adjustReps(weekday, index, delta),
                  ),
                ),
              ],
            ),
            footer: PillButton(
              variant: PillButtonVariant.outline,
              height: AppSizes.s44,
              label: 'Remove exercise',
              icon: Icons.delete_outline_rounded,
              labelColor: colors.destructiveBorder,
              iconColor: colors.destructiveBorder,
              onPressed: () {
                HapticManager.medium();
                Navigator.of(context).maybePop();
                viewModel.removeExercise(weekday, index);
              },
            ),
          ),
        );
      },
    );
  }
}
