import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/profile/view_models/edit_daily_targets_view_model.dart';
import 'package:floww/core/profile/widgets/profile_targets_card.dart';
import 'package:floww/core/profile/widgets/profile_targets_note_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class EditDailyTargetsView extends StatelessWidget {
  const EditDailyTargetsView({super.key});

  Future<void> _save(EditDailyTargetsViewModel viewModel) async {
    if (!await viewModel.save()) {
      HapticManager.error();
      return;
    }
    HapticManager.success();
    NavigationService.instance.pop();
  }

  Future<void> _handleBack(
    BuildContext context,
    EditDailyTargetsViewModel viewModel,
  ) async {
    if (!viewModel.hasUnsavedChanges) {
      NavigationService.instance.pop();
      return;
    }

    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.unsavedTitle,
      message: viewModel.unsavedMessage,
      confirmLabel: viewModel.saveLabel,
      alternateLabel: viewModel.discardLabel,
    );

    switch (choice) {
      case AppConfirmChoice.confirm:
        await _save(viewModel);
      case AppConfirmChoice.alternate:
        NavigationService.instance.pop();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditDailyTargetsViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return PopScope(
          canPop: !viewModel.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBack(context, viewModel);
          },
          child: InnerPageScaffold(
            title: viewModel.title,
            onBack: () => _handleBack(context, viewModel),
            footer: PillButton(
              variant: PillButtonVariant.primary,
              label: viewModel.saveLabel,
              isLoading: viewModel.isSaving,
              onPressed: viewModel.isLoading ? null : () => _save(viewModel),
            ),
            children: [
              if (viewModel.isLoading)
                const AppSectionLoader()
              else ...[
                if (errorMessage != null) ...[
                  AppErrorCard(message: errorMessage, onRetry: viewModel.load),
                  SizedBox(height: AppSpacing.xl2),
                ],
                ProfileTargetsNoteCard(message: viewModel.note),
                SizedBox(height: AppSpacing.xl2),
                ProfileTargetsCard(
                  specs: viewModel.specs,
                  labelOf: viewModel.valueLabel,
                  onChanged: viewModel.updateTarget,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
