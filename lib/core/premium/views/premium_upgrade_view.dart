import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/animated_value_text.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/view_models/premium_upgrade_view_model.dart';
import 'package:floww/core/premium/views/premium_success_sheet.dart';
import 'package:floww/core/premium/widgets/premium_plan_overview_card.dart';
import 'package:floww/core/premium/widgets/premium_price_card.dart';
import 'package:floww/core/premium/widgets/premium_saved_notice.dart';
import 'package:floww/core/premium/widgets/premium_segmented_tabs.dart';
import 'package:floww/core/premium/widgets/premium_store_links.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PremiumUpgradeView extends StatelessWidget {
  const PremiumUpgradeView({super.key});

  void _selectTerm(PremiumUpgradeViewModel viewModel, SubscriptionTerm term) {
    HapticManager.selection();
    viewModel.selectTerm(term);
  }

  Future<void> _purchase(
    BuildContext context,
    PremiumUpgradeViewModel viewModel,
  ) async {
    final purchased = await viewModel.purchase();
    if (purchased == null) {
      HapticManager.error();
      return;
    }
    HapticManager.success();
    if (!context.mounted) return;
    await PremiumSuccessSheet.show(context: context, viewModel: viewModel);
  }

  Future<void> _restore(
    BuildContext context,
    PremiumUpgradeViewModel viewModel,
  ) async {
    HapticManager.light();
    final restored = await viewModel.restore();
    if (restored == null) return;
    HapticManager.success();
    if (!context.mounted) return;
    await PremiumSuccessSheet.show(context: context, viewModel: viewModel);
  }

  List<PremiumStoreLink> _links(
    BuildContext context,
    PremiumUpgradeViewModel viewModel,
  ) => [
    PremiumStoreLink(
      label: viewModel.restoreLabel,
      onTap: viewModel.isBusy ? null : () => _restore(context, viewModel),
    ),
    PremiumStoreLink(label: viewModel.termsLabel, onTap: viewModel.openTerms),
    if (viewModel.hasPrivacyLink)
      PremiumStoreLink(
        label: viewModel.privacyLabel,
        onTap: viewModel.openPrivacy,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumUpgradeViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final noticeMessage = viewModel.noticeMessage;

        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          footer: _PremiumUpgradeFooter(
            label: viewModel.ctaLabel,
            footnote: viewModel.footnoteLabel,
            isLoading: viewModel.isPurchasing,
            onPressed: viewModel.isBusy
                ? null
                : () => _purchase(context, viewModel),
            links: _links(context, viewModel),
          ),
          children: [
            if (errorMessage != null) ...[
              AppErrorCard(message: errorMessage),
              SizedBox(height: AppSpacing.xl2),
            ],
            if (noticeMessage != null) ...[
              PremiumSavedNotice(
                message: noticeMessage,
                onDismiss: viewModel.dismissNotice,
              ),
              SizedBox(height: AppSpacing.xl2),
            ],
            PremiumSegmentedTabs<SubscriptionTerm>(
              items: viewModel.terms,
              selected: viewModel.selectedTerm,
              labelOf: viewModel.tabLabel,
              badgeOf: viewModel.tabBadgeLabel,
              onSelected: (term) => _selectTerm(viewModel, term),
            ),
            SizedBox(height: AppSpacing.xl2),
            PremiumPriceCard(
              selectionIndex: viewModel.terms.indexOf(viewModel.selectedTerm),
              priceLabel: viewModel.priceLabel,
              periodLabel: viewModel.periodLabel,
              highlightLabel: viewModel.highlightLabel,
              savingsLabel: viewModel.savingsLabel,
            ),
            SizedBox(height: AppSpacing.xl2),
            PremiumPlanOverviewCard(
              title: viewModel.planTitle,
              subtitle: viewModel.planSubtitle,
              features: viewModel.features,
            ),
            SizedBox(height: AppSpacing.xl5),
          ],
        );
      },
    );
  }
}

class _PremiumUpgradeFooter extends StatelessWidget {
  const _PremiumUpgradeFooter({
    required this.label,
    required this.footnote,
    required this.isLoading,
    required this.onPressed,
    required this.links,
  });

  final String label;
  final String footnote;
  final bool isLoading;
  final VoidCallback? onPressed;
  final List<PremiumStoreLink> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillButton(
          variant: PillButtonVariant.primary,
          isLoading: isLoading,
          onPressed: onPressed,
          child: AnimatedValueText(
            value: label,
            alignment: Alignment.center,
            textAlign: TextAlign.center,
            style: AppTypography.heading4SemiBold.copyWith(
              color: context.colors.backgroundSecondary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          footnote,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: context.colors.textSubtle,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        PremiumStoreLinks(links: links),
      ],
    );
  }
}
