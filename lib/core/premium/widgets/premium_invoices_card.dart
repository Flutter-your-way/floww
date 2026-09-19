import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';

class PremiumInvoicesCard extends StatelessWidget {
  const PremiumInvoicesCard({
    super.key,
    required this.title,
    required this.invoices,
    required this.exportLabel,
    this.onOpenAll,
    this.onInvoiceTap,
    this.onExport,
    this.isExporting = false,
  });

  static const IconData invoiceIcon = Icons.receipt_long_rounded;

  final String title;
  final List<PremiumInvoiceItem> invoices;
  final String exportLabel;
  final VoidCallback? onOpenAll;
  final ValueChanged<PremiumInvoiceItem>? onInvoiceTap;
  final VoidCallback? onExport;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onInvoiceTap = this.onInvoiceTap;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.heading4SemiBold,
            showChevron: true,
            onTap: onOpenAll,
          ),
          for (final invoice in invoices) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: colors.borderSubtle,
            ),
            _PremiumInvoiceRow(
              invoice: invoice,
              onTap: onInvoiceTap == null ? null : () => onInvoiceTap(invoice),
            ),
          ],
          Divider(
            height: AppSpacing.xl2,
            thickness: AppSizes.s1,
            color: colors.borderSubtle,
          ),
          _PremiumExportAction(
            label: exportLabel,
            onTap: onExport,
            isLoading: isExporting,
          ),
        ],
      ),
    );
  }
}

class _PremiumInvoiceRow extends StatelessWidget {
  const _PremiumInvoiceRow({required this.invoice, this.onTap});

  final PremiumInvoiceItem invoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        const AppIconTile(icon: PremiumInvoicesCard.invoiceIcon),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      invoice.amountLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLargeBold,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  AppStatusChip(
                    label: invoice.statusLabel,
                    variant: AppStatusChipVariant.outlined,
                    height: AppSizes.s24,
                    labelStyle: AppTypography.bodySmallSemiBold,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                invoice.subtitle,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        PillButton(
          variant: PillButtonVariant.outline,
          height: AppSizes.s40,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          icon: Icons.description_outlined,
          label: invoice.actionLabel,
          labelStyle: AppTypography.labelMediumSemiBold,
          isLoading: invoice.isDownloading,
          onPressed: onTap,
        ),
      ],
    );
  }
}

class _PremiumExportAction extends StatelessWidget {
  const _PremiumExportAction({
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  static const double _loaderStroke = 2;

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: isLoading ? null : onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: AppSizes.s20,
              height: AppSizes.s20,
              child: CircularProgressIndicator(
                strokeWidth: _loaderStroke,
                color: colors.primary,
              ),
            )
          else
            Icon(
              Icons.download_rounded,
              size: AppSizes.s20,
              color: colors.primary,
            ),
          SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTypography.bodyLargeSemiBold.copyWith(
              color: colors.primary,
              decoration: TextDecoration.underline,
              decorationColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
