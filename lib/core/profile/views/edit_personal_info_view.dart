import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/view_models/edit_personal_info_view_model.dart';
import 'package:floww/core/profile/widgets/profile_choice_card.dart';
import 'package:floww/core/profile/widgets/profile_edit_field.dart';
import 'package:floww/core/profile/widgets/profile_unit_dropdown.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class EditPersonalInfoView extends StatelessWidget {
  const EditPersonalInfoView({super.key});

  Future<void> _save(EditPersonalInfoViewModel viewModel) async {
    if (!await viewModel.save()) {
      HapticManager.error();
      return;
    }
    HapticManager.success();
    NavigationService.instance.pop();
  }

  Future<void> _handleBack(
    BuildContext context,
    EditPersonalInfoViewModel viewModel,
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
    return Consumer<EditPersonalInfoViewModel>(
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
                _PersonalDetailsCard(viewModel: viewModel),
                SizedBox(height: AppSpacing.xl2),
                ProfileChoiceCard(
                  group: viewModel.goalGroup,
                  onSelected: viewModel.selectGoal,
                ),
                SizedBox(height: AppSpacing.xl2),
                ProfileChoiceCard(
                  group: viewModel.dietGroup,
                  onSelected: viewModel.selectDiet,
                ),
                SizedBox(height: AppSpacing.xl2),
                ProfileChoiceCard(
                  group: viewModel.experienceGroup,
                  onSelected: viewModel.selectExperience,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard({required this.viewModel});

  final EditPersonalInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileEditField(
            label: viewModel.nameLabel,
            hint: viewModel.nameHint,
            controller: viewModel.nameController,
            onChanged: viewModel.updateName,
          ),
          SizedBox(height: AppSpacing.xl2),
          ProfileEditField(
            label: viewModel.heightLabel,
            hint: viewModel.heightHint,
            controller: viewModel.heightController,
            onChanged: viewModel.updateHeight,
            isNumeric: true,
            trailing: ProfileUnitDropdown<HeightUnit>(
              value: viewModel.heightUnit,
              values: viewModel.heightUnits,
              labelOf: viewModel.heightUnitLabel,
              onSelected: viewModel.selectHeightUnit,
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          ProfileEditField(
            label: viewModel.weightLabel,
            hint: viewModel.weightHint,
            controller: viewModel.weightController,
            onChanged: viewModel.updateWeight,
            isNumeric: true,
            trailing: ProfileUnitDropdown<WeightUnit>(
              value: viewModel.weightUnit,
              values: viewModel.weightUnits,
              labelOf: viewModel.weightUnitLabel,
              onSelected: viewModel.selectWeightUnit,
            ),
          ),
        ],
      ),
    );
  }
}
