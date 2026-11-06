import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/config/widgets/text_field/custom_text_form_field.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailSignInView extends StatefulWidget {
  const EmailSignInView({super.key});

  @override
  State<EmailSignInView> createState() => _EmailSignInViewState();
}

class _EmailSignInViewState extends State<EmailSignInView> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AuthViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.clearError());
  }

  Future<void> _submit(AuthViewModel viewModel) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await viewModel.signInWithEmail();
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomHeader(
                title: "Account Setup",
                onBackPressed: NavigationService.instance.pop,
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                viewModel.emailTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                viewModel.emailSubtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              SizedBox(height: AppSpacing.xl4),
              CustomTextFormField(
                hintText: viewModel.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onChanged: viewModel.updateEmail,
              ),
              SizedBox(height: AppSpacing.lg),
              CustomTextFormField(
                hintText: viewModel.passwordHint,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onChanged: viewModel.updatePassword,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: context.colors.textSecondary,
                    size: AppSizes.s20,
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
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.destructive,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: AppSpacing.xl3),
              CustomButton(
                text: "Continue",
                backgroundColor: context.colors.brandLight,
                foregroundColor: context.colors.backgroundPrimary,
                isLoading: viewModel.isEmailLoading,
                isDisabled: !viewModel.canSubmitEmail,
                onPressed: () => _submit(viewModel),
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
