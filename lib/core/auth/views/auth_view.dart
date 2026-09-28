import 'dart:io';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
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

class _AuthViewState extends State<AuthView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().requestNotificationPermission();
  }

  void _continueToOnboarding() {
    NavigationService.instance.push(AppRouter.home);
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
    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              CustomHeader(
                title: "Account Setup",
                onBackPressed: () => NavigationService.instance.pop(),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                "Create your account",
                textAlign: TextAlign.center,
                style: context.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                "Sign in to save your plan and sync your progress across devices.",
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              Consumer<AuthViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.errorMessage == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.destructive,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Consumer<AuthViewModel>(
                builder: (context, viewModel, _) {
                  return Column(
                    children: [
                      CustomButton(
                        text: "Sign in with Google",
                        backgroundColor: Colors.white,
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
                      if (Platform.isIOS) ...[
                        SizedBox(height: AppSpacing.lg),
                        CustomOutlinedButton(
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
                      ],
                    ],
                  );
                },
              ),
              SizedBox(height: AppSpacing.xl3),
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.borderSubtle)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      "or continue as guest",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.borderSubtle)),
                ],
              ),
              SizedBox(height: AppSpacing.xl3),
              CustomOutlinedButton(
                text: "Skip for Now",
                onPressed: _continueToOnboarding,
              ),
              SizedBox(height: AppSpacing.xl3),
              Text.rich(
                TextSpan(
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                  children: [
                    const TextSpan(text: "By continuing, you agree to our "),
                    TextSpan(
                      text: "Terms of Service",
                      style: TextStyle(color: context.colors.primary),
                    ),
                    const TextSpan(text: " and \n"),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(color: context.colors.primary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }
}
