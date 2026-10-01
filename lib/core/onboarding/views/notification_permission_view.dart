import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/animations/staggered_reveal_mixin.dart';
import 'package:floww/config/widgets/animations/step_reveal_item.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/core/onboarding/providers/notification_permission_provider.dart';
import 'package:floww/core/onboarding/widgets/notification_preview_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPermissionView extends StatefulWidget {
  const NotificationPermissionView({super.key});

  @override
  State<NotificationPermissionView> createState() =>
      _NotificationPermissionViewState();
}

class _NotificationPermissionViewState extends State<NotificationPermissionView>
    with SingleTickerProviderStateMixin, StaggeredRevealMixin {
  static const double _olderPreviewOpacity = 0.55;

  @override
  int get revealCount => 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(AppMotion.permissionPromptDelay, () {
      if (!mounted) return;
      context.read<NotificationPermissionProvider>().promptOnce();
    });
  }

  void _handlePrimary(NotificationPermissionProvider provider) {
    if (provider.hasAnswered) {
      NavigationService.instance.pushAndRemoveUntil(AppRouter.home);
      return;
    }
    provider.allow();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationPermissionProvider>();
    final previews = provider.previews;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
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
                          const Spacer(flex: 2),
                          StepRevealItem(
                            presence: presence(0),
                            child: NotificationPreviewCard(
                              appName: provider.appName,
                              preview: previews.first,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          StepRevealItem(
                            presence: presence(1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Opacity(
                                opacity: _olderPreviewOpacity,
                                child: NotificationPreviewCard(
                                  appName: provider.appName,
                                  preview: previews.last,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl5),
                          StepRevealItem(
                            presence: presence(2),
                            child: Text(
                              provider.title,
                              textAlign: TextAlign.center,
                              style: context.textTheme.displayLarge,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          StepRevealItem(
                            presence: presence(3),
                            child: Text(
                              provider.subtitle,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colors.textMuted,
                              ),
                            ),
                          ),
                          const Spacer(flex: 3),
                          StepRevealItem(
                            presence: presence(4),
                            child: Column(
                              children: [
                                AnimatedSwitcher(
                                  duration: AppMotion.fast,
                                  child: Text(
                                    provider.statusNote,
                                    key: ValueKey(provider.status),
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context.colors.textFaint,
                                        ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.lg),
                                CustomButton(
                                  text: provider.primaryLabel,
                                  isLoading: provider.isRequesting,
                                  onPressed: () => _handlePrimary(provider),
                                ),
                              ],
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
      ),
    );
  }
}
