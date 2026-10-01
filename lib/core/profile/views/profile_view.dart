import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';
import 'package:floww/core/profile/view_models/profile_view_model.dart';
import 'package:floww/core/profile/widgets/profile_identity_card.dart';
import 'package:floww/core/profile/widgets/profile_log_out_button.dart';
import 'package:floww/core/profile/widgets/profile_metric_card.dart';
import 'package:floww/core/profile/widgets/profile_settings_card.dart';
import 'package:floww/core/profile/widgets/profile_subscription_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _openPremium(ProfileViewModel viewModel) {
    HapticManager.light();
    NavigationService.instance.push(viewModel.subscriptionRoute);
  }

  void _openPhoto(ProfileViewModel viewModel) {
    HapticManager.light();
    NavigationService.instance.push(
      AppRouter.profilePhoto,
      arguments: viewModel.photoArgs,
    );
  }

  void _edit(String route) {
    HapticManager.light();
    NavigationService.instance.push(route);
  }

  void _openSetting(ProfileSettingItem item) {
    HapticManager.light();
    NavigationService.instance.push(item.route);
  }

  Future<void> _confirmLogOut(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    HapticManager.light();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.logOutTitle,
      message: viewModel.logOutMessage,
      confirmLabel: viewModel.logOutLabel,
      alternateLabel: viewModel.cancelLabel,
      icon: Icons.logout_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    await _logOut(viewModel);
  }

  Future<void> _logOut(ProfileViewModel viewModel) async {
    HapticManager.warning();
    if (await viewModel.logOut()) {
      await NavigationService.instance.pushAndRemoveUntil(
        AppRouter.accountSetup,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (viewModel.isLoading)
              const AppSectionLoader()
            else ...[
              if (errorMessage != null) ...[
                AppErrorCard(message: errorMessage),
                SizedBox(height: AppSpacing.xl2),
              ],
              ProfileIdentityCard(
                summary: viewModel.summary,
                badgeLabel: viewModel.premiumBadgeLabel,
                onAvatarTap: () => _openPhoto(viewModel),
              ),
              SizedBox(height: AppSpacing.xl2),
              ProfileMetricCard(
                section: viewModel.personalInformation,
                onEdit: () => _edit(AppRouter.editPersonalInfo),
              ),
              SizedBox(height: AppSpacing.xl2),
              ProfileMetricCard(
                section: viewModel.dailyTargets,
                onEdit: () => _edit(AppRouter.editDailyTargets),
              ),
              SizedBox(height: AppSpacing.xl2),
              ProfileSubscriptionCard(
                subscription: viewModel.subscription,
                onAction: () => _openPremium(viewModel),
              ),
              SizedBox(height: AppSpacing.xl2),
              ProfileSettingsCard(
                title: viewModel.settingsTitle,
                items: viewModel.settings,
                onItemTap: _openSetting,
              ),
              SizedBox(height: AppSpacing.xl2),
              ProfileLogOutButton(
                label: viewModel.logOutLabel,
                onPressed: viewModel.isSigningOut
                    ? null
                    : () => _confirmLogOut(context, viewModel),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                viewModel.versionLabel,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: context.colors.textDim,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
