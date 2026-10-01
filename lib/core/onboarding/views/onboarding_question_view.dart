import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_analysis_screen.dart';
import '../widgets/onboarding_blueprint_screen.dart';
import '../widgets/onboarding_question_renderer.dart';

class OnboardingQuestionView extends StatefulWidget {
  const OnboardingQuestionView({super.key});

  @override
  State<OnboardingQuestionView> createState() => _OnboardingQuestionViewState();
}

class _OnboardingQuestionViewState extends State<OnboardingQuestionView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    final completed = await provider.nextQuestion(_pageController);
    if (completed && mounted) {
      NavigationService.instance.pushAndRemoveUntil(AppRouter.connectWearables);
    }
  }

  void _handleBack(OnboardingProvider provider) {
    if (provider.currentPhaseIndex == 0 && provider.currentQuestionIndex == 0) {
      _confirmLogOut();
    } else {
      provider.previousQuestion(_pageController);
    }
  }

  Future<void> _confirmLogOut() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isSigningOut) return;
    final choice = await AppConfirmSheet.show(
      context,
      title: authViewModel.logOutTitle,
      message: authViewModel.logOutMessage,
      confirmLabel: authViewModel.logOutLabel,
      alternateLabel: authViewModel.cancelLabel,
      icon: Icons.logout_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    if (await authViewModel.signOut() && mounted) {
      NavigationService.instance.pushAndRemoveUntil(AppRouter.accountSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We provide the OnboardingProvider here, though it could also be provided higher up in the app routing.
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Scaffold(
        body: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            final bottomReserve =
                AppSizes.s56 +
                AppSpacing.xl +
                MediaQuery.paddingOf(context).bottom;
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _handleBack(provider);
              },
              child: Stack(
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
                            title: provider.currentPhase.title,
                            onBackPressed: () => _handleBack(provider),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          LinearProgressIndicator(
                            value: provider.globalProgress,
                            color: context.colors.primary,
                            backgroundColor: context.colors.backgroundSurface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          SizedBox(height: AppSpacing.xl5),

                          // The main scrolling view
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              physics:
                                  const NeverScrollableScrollPhysics(), // Only move via buttons
                              // We flatten all active phases into a single continuous list of questions for the PageView
                              itemCount: provider.activePhases.fold<int>(
                                0,
                                (sum, phase) => sum + phase.questions.length,
                              ),
                              itemBuilder: (context, index) {
                                // Find which phase and question this global index corresponds to
                                int accumulated = 0;
                                for (var phase in provider.activePhases) {
                                  if (index <
                                      accumulated + phase.questions.length) {
                                    final question =
                                        phase.questions[index - accumulated];
                                    return OnboardingQuestionRenderer(
                                      question: question,
                                    );
                                  }
                                  accumulated += phase.questions.length;
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),

                          SizedBox(height: bottomReserve),
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
                          MediaQuery.paddingOf(context).bottom +
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
                          if (provider.submitError != null) ...[
                            Text(
                              provider.submitError!,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.destructive,
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                          ],
                          // Bottom Navigation
                          CustomButton(
                            text: "Continue",
                            isLoading: provider.isSubmitting,
                            // Disable button if answer is missing
                            onPressed: provider.canContinue
                                ? () => _handleContinue(provider)
                                : null,
                          ),
                          SizedBox(
                            height:
                                MediaQuery.paddingOf(context).bottom +
                                AppSpacing.xl,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: AppMotion.analysisScreen,
                      switchInCurve: AppMotion.analysisCurve,
                      switchOutCurve: AppMotion.analysisCurve,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: AppMotion.analysisExitScale,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _fullScreenStep(provider),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fullScreenStep(OnboardingProvider provider) {
    final analysis = provider.analysis;
    if (provider.isOnBlueprint && analysis != null) {
      return OnboardingBlueprintScreen(
        key: const ValueKey('onboarding-blueprint'),
        title: provider.blueprintTitle,
        analysis: analysis,
        isSubmitting: provider.isSubmitting,
        error: provider.submitError,
        onEnter: () => _handleContinue(provider),
      );
    }
    if (provider.isOnAnalysis) {
      return OnboardingAnalysisScreen(
        key: const ValueKey('onboarding-analysis'),
        title: provider.currentQuestion.title,
        steps: provider.analysisSteps,
        error: provider.isAnalyzing ? null : provider.analysisError,
        onRetry: () => provider.analyzeProfile(_pageController),
        onBack: () => _handleBack(provider),
      );
    }
    return const SizedBox.shrink(key: ValueKey('onboarding-questions'));
  }
}
