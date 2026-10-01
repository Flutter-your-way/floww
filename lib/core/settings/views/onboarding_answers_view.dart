import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/view_models/onboarding_answers_view_model.dart';
import 'package:floww/core/settings/widgets/onboarding_answers_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class OnboardingAnswersView extends StatelessWidget {
  const OnboardingAnswersView({super.key});

  Future<void> _edit(
    OnboardingAnswersViewModel viewModel,
    OnboardingAnswerItem item,
  ) async {
    HapticManager.light();
    final saved = await NavigationService.instance.push(
      AppRouter.editOnboardingAnswer,
      arguments: viewModel.editArgsFor(item.question),
    );
    if (saved == true) await viewModel.load();
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
                  onItemTap: (item) => _edit(viewModel, item),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
