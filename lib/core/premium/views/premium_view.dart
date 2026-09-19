import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/tab_content_switcher.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/view_models/premium_view_model.dart';
import 'package:floww/core/premium/views/cancel_subscription_sheet.dart';
import 'package:floww/core/premium/widgets/premium_features_card.dart';
import 'package:floww/core/premium/widgets/premium_invoices_card.dart';
import 'package:floww/core/premium/widgets/premium_payment_method_card.dart';
import 'package:floww/core/premium/widgets/premium_payments_summary_card.dart';
import 'package:floww/core/premium/widgets/premium_renewal_card.dart';
import 'package:floww/core/premium/widgets/premium_saved_notice.dart';
import 'package:floww/core/premium/widgets/premium_segmented_tabs.dart';
import 'package:floww/core/premium/widgets/premium_status_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  void _selectTab(PremiumViewModel viewModel, PremiumTab tab) {
    HapticManager.selection();
    viewModel.selectTab(tab);
  }

  void _openUpgrade() {
    HapticManager.light();
    NavigationService.instance.pushReplacement(AppRouter.premiumUpgrade);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumViewModel>(
      builder: (context, viewModel, child) {
        final errorMessage = viewModel.errorMessage;
        final savedMessage = viewModel.savedMessage;

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
              if (savedMessage != null) ...[
                PremiumSavedNotice(
                  message: savedMessage,
                  onDismiss: viewModel.dismissSavedMessage,
                ),
                SizedBox(height: AppSpacing.xl2),
              ],
              PremiumSegmentedTabs<PremiumTab>(
                items: viewModel.tabs,
                selected: viewModel.selectedTab,
                labelOf: viewModel.tabLabel,
                onSelected: (tab) => _selectTab(viewModel, tab),
              ),
              SizedBox(height: AppSpacing.xl2),
              TabContentSwitcher(
                reverse: viewModel.tabReverse,
                child: KeyedSubtree(
                  key: ValueKey(viewModel.selectedTab),
                  child: viewModel.isPlanTab
                      ? _PremiumPlanTab(
                          viewModel: viewModel,
                          onUpgrade: _openUpgrade,
                        )
                      : _PremiumPaymentsTab(viewModel: viewModel),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PremiumPlanTab extends StatelessWidget {
  const _PremiumPlanTab({required this.viewModel, required this.onUpgrade});

  final PremiumViewModel viewModel;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumStatusCard(
          badgeLabel: viewModel.statusBadgeLabel,
          planLabel: viewModel.planSummaryLabel,
          title: viewModel.statusTitle,
          message: viewModel.statusMessage,
          actionLabel: viewModel.statusActionLabel,
          onAction: onUpgrade,
        ),
        SizedBox(height: AppSpacing.xl2),
        PremiumFeaturesCard(
          title: viewModel.featuresTitle,
          features: viewModel.features,
        ),
        if (viewModel.isActive) ...[
          SizedBox(height: AppSpacing.xl2),
          PremiumRenewalCard(
            renewalLabel: viewModel.renewalLabel,
            cancelLabel: viewModel.cancelLabel,
            onCancel: () => CancelSubscriptionSheet.show(
              context: context,
              viewModel: viewModel,
            ),
          ),
        ],
      ],
    );
  }
}

class _PremiumPaymentsTab extends StatelessWidget {
  const _PremiumPaymentsTab({required this.viewModel});

  final PremiumViewModel viewModel;

  void _downloadInvoice(PremiumInvoiceItem invoice) {
    HapticManager.light();
    viewModel.downloadInvoice(invoice.id);
  }

  void _exportAll() {
    HapticManager.light();
    viewModel.exportAllInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.hasPayments) ...[
          PremiumPaymentsSummaryCard(
            totalLabel: viewModel.totalPaidLabel,
            totalCaption: viewModel.totalPaidCaption,
            countLabel: viewModel.paymentCountLabel,
            sinceLabel: viewModel.paymentsSinceLabel,
          ),
          SizedBox(height: AppSpacing.xl2),
          PremiumInvoicesCard(
            title: viewModel.invoicesTitle,
            invoices: viewModel.invoices,
            exportLabel: viewModel.exportInvoicesLabel,
            isExporting: viewModel.isExportingAll,
            onOpenAll: _exportAll,
            onInvoiceTap: _downloadInvoice,
            onExport: _exportAll,
          ),
          SizedBox(height: AppSpacing.xl2),
        ] else ...[
          PremiumStatusCard(
            planLabel: viewModel.paymentsSinceLabel,
            title: viewModel.emptyPaymentsTitle,
            message: viewModel.emptyPaymentsMessage,
          ),
          SizedBox(height: AppSpacing.xl2),
        ],
        PremiumPaymentMethodCard(
          title: viewModel.paymentMethodTitle,
          methodLabel: viewModel.paymentMethodLabel,
          expiryLabel: viewModel.paymentMethodExpiryLabel,
          actionLabel: viewModel.paymentMethodActionLabel,
          onUpdate: HapticManager.light,
        ),
      ],
    );
  }
}
