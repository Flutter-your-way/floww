import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/onboarding/widgets/onboarding_question_renderer.dart';
import 'package:floww/core/settings/view_models/onboarding_answer_edit_view_model.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class OnboardingAnswerEditView extends StatelessWidget {
  const OnboardingAnswerEditView({super.key});

  void _back(OnboardingAnswerEditViewModel viewModel) {
    if (viewModel.back()) return;
    NavigationService.instance.pop(false);
  }

  Future<void> _proceed(OnboardingAnswerEditViewModel viewModel) async {
    HapticManager.light();
    if (await viewModel.proceed()) {
      HapticManager.success();
      NavigationService.instance.pop(true);
      return;
    }
    if (viewModel.errorMessage != null) HapticManager.error();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingAnswerEditViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final bottomInset = MediaQuery.paddingOf(context).bottom;

        return ChangeNotifierProvider.value(
          value: viewModel.answers,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back(viewModel);
            },
            child: Scaffold(
              body: Stack(
                children: [
                  const Positioned.fill(
                    child: AppBackground(child: SizedBox.shrink()),
                  ),
                  SafeArea(
                    bottom: false,
                    left: false,
                    right: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        children: [
                          CustomHeader(
                            title: viewModel.phase.title,
                            onBackPressed: () => _back(viewModel),
                          ),
                          SizedBox(height: AppSpacing.xl5),
                          Expanded(
                            child: OnboardingQuestionRenderer(
                              key: ValueKey(viewModel.question.id),
                              question: viewModel.question,
                            ),
                          ),
                          SizedBox(
                            height: AppSizes.s56 + AppSpacing.xl + bottomInset,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomActionScrim(
                      height:
                          bottomInset +
                          AppSizes.s72 +
                          context.sizes.bottomScrimExtra,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (errorMessage != null) ...[
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.destructive,
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                          ],
                          CustomButton(
                            text: viewModel.actionLabel,
                            isLoading: viewModel.isSaving,
                            onPressed: viewModel.canContinue
                                ? () => _proceed(viewModel)
                                : null,
                          ),
                          SizedBox(height: bottomInset + AppSpacing.xl),
                        ],
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
