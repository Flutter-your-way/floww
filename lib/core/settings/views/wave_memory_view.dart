import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/cards/app_info_note.dart';
import 'package:floww/config/widgets/cards/app_toggle_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/view_models/wave_memory_view_model.dart';
import 'package:floww/core/settings/views/delete_account_sheet.dart';
import 'package:floww/core/settings/widgets/danger_zone_card.dart';
import 'package:floww/core/settings/widgets/wave_memory_section_card.dart';
import 'package:floww/core/settings/widgets/wave_memory_summary_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WaveMemoryView extends StatelessWidget {
  const WaveMemoryView({super.key});

  Future<void> _confirmForget(
    BuildContext context,
    WaveMemoryViewModel viewModel,
  ) async {
    HapticManager.warning();
    final confirmed = await DeleteAccountSheet.show(
      context,
      title: WaveMemoryViewModel.forgetPromptTitle,
      message: WaveMemoryViewModel.forgetPromptMessage,
      confirmLabel: WaveMemoryViewModel.forgetConfirmLabel,
    );
    if (confirmed == true) await viewModel.forgetEverything();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaveMemoryViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: WaveMemoryViewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            AppToggleCard(
              icon: Icons.psychology_outlined,
              title: WaveMemoryViewModel.toggleTitle,
              subtitle: viewModel.toggleSubtitle,
              value: viewModel.isEnabled,
              onChanged: (value) {
                HapticManager.light();
                viewModel.setEnabled(value);
              },
            ),
            SizedBox(height: AppSpacing.xl),
            const AppInfoNote(
              text: WaveMemoryViewModel.explainer,
              icon: Icons.info_outline_rounded,
            ),
            if (errorMessage != null) ...[
              SizedBox(height: AppSpacing.xl2),
              AppErrorCard(message: errorMessage),
            ],
            SizedBox(height: AppSpacing.xl2),
            if (viewModel.isLoading)
              const AppSectionLoader()
            else if (viewModel.isEmpty)
              const AppEmptyStateCard(
                title: WaveMemoryViewModel.emptyTitle,
                message: WaveMemoryViewModel.emptyMessage,
                icon: Icons.psychology_outlined,
              )
            else ...[
              for (final group in viewModel.groups) ...[
                WaveMemorySectionCard(
                  category: group.category,
                  notes: group.notes,
                  onDelete: (note) {
                    HapticManager.light();
                    viewModel.deleteNote(note);
                  },
                ),
                SizedBox(height: AppSpacing.xl2),
              ],
              if (viewModel.hasSummary) ...[
                WaveMemorySummaryCard(
                  title: WaveMemoryViewModel.summaryTitle,
                  subtitle: WaveMemoryViewModel.summarySubtitle,
                  groups: viewModel.summaryGroups,
                  toggleLabel: viewModel.summaryToggleLabel,
                  canToggle: viewModel.canToggleSummary,
                  onToggle: viewModel.toggleSummaryExpanded,
                  onDelete: (item) {
                    HapticManager.light();
                    viewModel.deleteSummaryItem(item);
                  },
                  onClear: () {
                    HapticManager.light();
                    viewModel.clearSummary();
                  },
                ),
                SizedBox(height: AppSpacing.xl2),
              ],
              DangerZoneCard(
                title: WaveMemoryViewModel.dangerTitle,
                actionTitle: WaveMemoryViewModel.forgetTitle,
                actionSubtitle: viewModel.forgetActionSubtitle,
                isLoading: viewModel.isForgetting,
                onDelete: viewModel.canForget
                    ? () => _confirmForget(context, viewModel)
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}
