import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/buttons/radio_select_button/custom_radio_select_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/units_view_model.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class UnitsView extends StatelessWidget {
  const UnitsView({super.key});

  Future<void> _save(UnitsViewModel viewModel) async {
    if (!await viewModel.save()) {
      HapticManager.error();
      return;
    }
    HapticManager.success();
    NavigationService.instance.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitsViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
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
                SizedBox(height: AppSpacing.lg),
              ],
              AppCard(
                child: Text(
                  viewModel.note,
                  style: AppTypography.bodyMediumMedium.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ),
              for (final option in viewModel.options) ...[
                SizedBox(height: AppSpacing.lg),
                CustomRadioSelectButton(
                  title: option.title,
                  description: option.description,
                  isSelected: viewModel.isSelected(option.system),
                  onTap: () {
                    HapticManager.selection();
                    viewModel.select(option.system);
                  },
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
