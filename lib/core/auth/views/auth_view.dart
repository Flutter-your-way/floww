import 'dart:io';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/animations/staggered_reveal_mixin.dart';
import 'package:floww/config/widgets/animations/step_reveal_item.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_outlined_button.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin, StaggeredRevealMixin {
  @override
  int get revealCount => 5;

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().markIntroSeen();
  }

  Future<void> _handleSignIn(
    AuthViewModel viewModel,
    Future<bool> Function() signIn,
  ) async {
    final success = await signIn();
    if (!success || !mounted) return;

    NavigationService.instance.pushAndRemoveUntil(
      AppRouter.routeAfterAuth(viewModel.currentUser!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final errorMessage = viewModel.errorMessage;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      children: [
                        const CustomHeader(title: "Account Setup"),
                        SizedBox(height: AppSpacing.xl),
                        StepRevealItem(
                          presence: presence(0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              viewModel.createAccountTitle,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: context.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        StepRevealItem(
                          presence: presence(1),
                          child: Text(
                            viewModel.createAccountSubtitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                        ),
                        AppPopReveal(
                          trigger: errorMessage,
                          child: errorMessage == null
                              ? null
                              : Padding(
                                  padding: EdgeInsets.only(top: AppSpacing.lg),
                                  child: Text(
                                    errorMessage,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context.colors.destructive,
                                        ),
                                  ),
                                ),
                        ),
                        const Spacer(),
                        SizedBox(height: AppSpacing.xl3),
                        StepRevealItem(
                          presence: presence(2),
                          child: CustomButton(
                            text: "Sign in with Google",
                            backgroundColor: context.colors.brandLight,
                            foregroundColor: context.colors.backgroundPrimary,
                            leading: SvgPicture.asset(
                              AppImages.googleIcon,
                              width: AppSizes.s20,
                              height: AppSizes.s20,
                            ),
                            isLoading: viewModel.isGoogleLoading,
                            isDisabled: viewModel.isBusy,
                            onPressed: () => _handleSignIn(
                              viewModel,
                              viewModel.signInWithGoogle,
                            ),
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          SizedBox(height: AppSpacing.lg),
                          StepRevealItem(
                            presence: presence(3),
                            child: CustomOutlinedButton(
                              text: "Sign in with Apple",
                              leading: Icon(
                                Icons.apple,
                                color: context.colors.textPrimary,
                                size: AppSizes.s20,
                              ),
                              isLoading: viewModel.isAppleLoading,
                              isDisabled: viewModel.isBusy,
                              onPressed: () => _handleSignIn(
                                viewModel,
                                viewModel.signInWithApple,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xl3),
                        StepRevealItem(
                          presence: presence(4),
                          child: Text.rich(
                            TextSpan(
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.textMuted,
                              ),
                              children: [
                                const TextSpan(
                                  text: "By continuing, you agree to our ",
                                ),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                    color: context.colors.primary,
                                  ),
                                ),
                                const TextSpan(text: " and \n"),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    color: context.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
