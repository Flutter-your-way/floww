import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/destructive_pill_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/set_input_card.dart';

class EditSetSheet extends StatelessWidget {
  const EditSetSheet({super.key});

  static Future<void> show(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
    int loggedIndex,
  ) async {
    viewModel.beginEditSet(loggedIndex);
    if (viewModel.editSet == null) return;
    await showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const EditSetSheet(),
      ),
    );
    viewModel.cancelEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final edit = viewModel.editSet;
        if (edit == null) return const SizedBox.shrink();

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: edit.title,
            icon: Icons.edit_rounded,
            onClose: () => Navigator.of(context).maybePop(),
            body: SetInputCard(
              primary: edit.primary,
              weight: edit.weight,
              reserve: edit.reserve,
              typeOptions: edit.typeOptions,
              onAdjustPrimary: viewModel.adjustEditPrimary,
              onAdjustWeight: viewModel.adjustEditWeight,
              onAdjustReserve: viewModel.adjustEditReserve,
              onSelectType: viewModel.selectEditType,
            ),
            footer: Row(
              children: [
                Expanded(
                  child: DestructivePillButton(
                    label: viewModel.editDeleteLabel,
                    onPressed: () {
                      HapticManager.warning();
                      viewModel.deleteEditedSet();
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: PillButton(
                    variant: PillButtonVariant.primary,
                    label: viewModel.editSaveLabel,
                    onPressed: () {
                      HapticManager.success();
                      viewModel.saveEditedSet();
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
