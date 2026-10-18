import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/view_models/onboarding_answers_view_model.dart';
import 'package:floww/core/settings/widgets/onboarding_answers_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class OnboardingAnswersView extends StatelessWidget {
  const OnboardingAnswersView({super.key});

  Future<void> _edit(
    BuildContext context,
    OnboardingAnswersViewModel viewModel,
    OnboardingAnswerItem item,
  ) async {
    HapticManager.light();
    final result = await NavigationService.instance.push(
      AppRouter.editOnboardingAnswer,
      arguments: viewModel.editArgsFor(item.question),
    );
    if (result is! OnboardingAnswerEditResult) return;
    await viewModel.load();
    if (result != OnboardingAnswerEditResult.trainingChanged ||
        !context.mounted) {
      return;
    }
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.rebuildTitle,
      message: viewModel.rebuildPrompt,
      confirmLabel: viewModel.rebuildConfirmLabel,
      alternateLabel: viewModel.rebuildLaterLabel,
      icon: Icons.auto_awesome_rounded,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    await viewModel.rebuildPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingAnswersViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else if (errorMessage != null)
              AppErrorCard(message: errorMessage, onRetry: viewModel.load)
            else ...[
              if (viewModel.rebuildMessage case final message?) ...[
                TipCard.note(
                  title: message,
                  icon: viewModel.isRebuilding
                      ? Icons.hourglass_top_rounded
                      : Icons.auto_awesome_rounded,
                ),
                SizedBox(height: AppSpacing.xl),
              ],
              AppCard(
                child: Text(
                  viewModel.note,
                  style: AppTypography.bodyMediumMedium.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ),
              for (final section in viewModel.sections) ...[
                SizedBox(height: AppSpacing.xl2),
                OnboardingAnswersCard(
                  section: section,
                  onItemTap: (item) => _edit(context, viewModel, item),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
