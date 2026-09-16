import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/utils/share/share_service.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/services/invoice_pdf_service.dart';
import 'package:floww/core/premium/view_models/premium_view_model.dart';

import 'support/fake_services.dart';

const PremiumCustomer customer = PremiumCustomer(
  name: 'Von Doe',
  email: 'von@floww.app',
  uid: 'test-uid',
);

void main() {
  const service = InvoicePdfService();

  group('invoice PDF', () {
    test('an invoice renders to a real PDF file', () async {
      final document = await service.buildInvoice(
        buildInvoice(id: 'a1b2c3d4e5f6', paidAt: DateTime(2026, 9, 16)),
        customer: customer,
      );

      expect(utf8.decode(document.bytes.take(4).toList()), '%PDF');
      expect(document.bytes.length, greaterThan(1000));
      expect(document.fileName, 'floww_invoice_2026-09-16_inv-a1b2c3d4');
    });

    test('the invoice number is derived from the document id', () {
      expect(InvoicePdfService.invoiceNumber('a1b2c3d4e5f6'), 'INV-A1B2C3D4');
      expect(InvoicePdfService.invoiceNumber('ab12'), 'INV-AB12');
    });

    test('the billing period spans the plan term', () {
      final yearly = buildInvoice(
        id: 'yearly',
        paidAt: DateTime(2026, 9, 16),
      );
      expect(
        InvoicePdfService.billingPeriod(yearly),
        'Sep 16, 2026 to Sep 16, 2027',
      );

      final monthly = SubscriptionInvoiceEntity(
        id: 'monthly',
        amount: AppSubscription.monthlyPrice,
        planLabel: 'Monthly Plan',
        paidAt: DateTime(2026, 9, 16),
        isPaid: true,
        isSimulated: true,
        planId: AppSubscription.monthlyPlanId,
      );
      expect(
        InvoicePdfService.billingPeriod(monthly),
        'Sep 16, 2026 to Oct 16, 2026',
      );
    });

    test('amounts print the currency code so no glyph is missing', () {
      final invoice = buildInvoice(id: 'x', paidAt: DateTime(2026, 9, 16));
      expect(InvoicePdfService.amountLabel(invoice), 'INR 3,999');
    });

    test('a statement renders every invoice into one PDF', () async {
      final document = await service.buildStatement(
        [
          buildInvoice(id: 'one', paidAt: DateTime(2026, 9, 16)),
          buildInvoice(id: 'two', paidAt: DateTime(2025, 9, 16)),
        ],
        customer: customer,
        generatedOn: DateTime(2026, 9, 20),
      );

      expect(utf8.decode(document.bytes.take(4).toList()), '%PDF');
      expect(document.fileName, 'floww_payment_statement_2026-09-20');
    });

    test('an empty statement is refused', () {
      expect(
        () => service.buildStatement(const [], customer: customer),
        throwsA(isA<InvoicePdfException>()),
      );
    });
  });

  group('downloading from the payments tab', () {
    test('tapping PDF builds that invoice and opens the share sheet', () async {
      final invoice = buildInvoice(id: 'one', paidAt: DateTime(2026, 9, 16));
      final pdf = FakeInvoicePdfService();
      final share = FakeShareService();
      final viewModel = PremiumViewModel(
        FakePremiumService(subscription: buildSubscription(), invoices: [
          invoice,
        ]),
        pdf,
        share,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(await viewModel.downloadInvoice('one'), isTrue);
      expect(pdf.builtInvoice?.id, 'one');
      expect(pdf.customer?.email, 'von@floww.app');
      expect(share.sharedNames, ['invoice.pdf']);
      expect(share.sharedMimeType, 'application/pdf');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.invoices.single.isDownloading, isFalse);
    });

    test('export all hands every invoice to one statement', () async {
      final pdf = FakeInvoicePdfService();
      final share = FakeShareService();
      final viewModel = PremiumViewModel(
        FakePremiumService(
          subscription: buildSubscription(),
          invoices: [
            buildInvoice(id: 'one', paidAt: DateTime(2026, 9, 16)),
            buildInvoice(id: 'two', paidAt: DateTime(2025, 9, 16)),
          ],
        ),
        pdf,
        share,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(await viewModel.exportAllInvoices(), isTrue);
      expect(pdf.builtStatement?.length, 2);
      expect(share.sharedNames, ['statement.pdf']);
      expect(viewModel.isExportingAll, isFalse);
    });

    test('a user with no invoices cannot export', () async {
      final pdf = FakeInvoicePdfService();
      final viewModel = PremiumViewModel(
        FakePremiumService(subscription: buildSubscription()),
        pdf,
        FakeShareService(),
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(await viewModel.exportAllInvoices(), isFalse);
      expect(pdf.builtStatement, isNull);
      expect(viewModel.errorMessage, 'There are no invoices to export yet.');
    });

    test('a failed share surfaces its message and clears the busy state',
        () async {
      final viewModel = PremiumViewModel(
        FakePremiumService(subscription: buildSubscription(), invoices: [
          buildInvoice(id: 'one', paidAt: DateTime(2026, 9, 16)),
        ]),
        FakeInvoicePdfService(),
        FakeShareService(
          failure: const ShareException(
            ShareErrorCode.shareFailed,
            'Could not open the share sheet. Please try again.',
          ),
        ),
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(await viewModel.downloadInvoice('one'), isFalse);
      expect(
        viewModel.errorMessage,
        'Could not open the share sheet. Please try again.',
      );
      expect(viewModel.isBusyWithPdf, isFalse);
    });

    test('a failed PDF build surfaces its message', () async {
      final viewModel = PremiumViewModel(
        FakePremiumService(subscription: buildSubscription(), invoices: [
          buildInvoice(id: 'one', paidAt: DateTime(2026, 9, 16)),
        ]),
        FakeInvoicePdfService(
          failure: InvoicePdfException('Could not create the PDF.'),
        ),
        FakeShareService(),
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(await viewModel.downloadInvoice('one'), isFalse);
      expect(viewModel.errorMessage, 'Could not create the PDF.');
    });
  });
}
