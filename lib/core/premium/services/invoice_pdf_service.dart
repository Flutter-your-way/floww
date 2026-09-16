import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/currency_formatter.dart';
import 'package:floww/core/premium/models/premium_customer.dart';

class InvoiceDocument {
  const InvoiceDocument({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class InvoicePdfException implements Exception {
  InvoicePdfException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvoicePdfService {
  const InvoicePdfService();

  static const String fileExtension = '.pdf';
  static const String mimeType = 'application/pdf';
  static const String brandName = 'FLOWW';
  static const String brandTagline = 'WAVE - AI Fitness Coaching';
  static const String invoicePrefix = 'INV-';
  static const int invoiceNumberLength = 8;

  static const PdfColor _ink = PdfColor.fromInt(0xFF0A0A0A);
  static const PdfColor _inkSubtle = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _accent = PdfColor.fromInt(0xFFC3FF3D);
  static const PdfColor _rule = PdfColor.fromInt(0xFFE4E4E4);
  static const PdfColor _surface = PdfColor.fromInt(0xFFF6F6F6);

  static const double _titleSize = 22;
  static const double _headingSize = 13;
  static const double _bodySize = 10;
  static const double _captionSize = 8.5;
  static const double _gutter = 32;
  static const double _gap = 8;
  static const double _blockGap = 22;

  static String invoiceNumber(String id) {
    final trimmed = id.replaceAll('-', '');
    final take = trimmed.length < invoiceNumberLength
        ? trimmed.length
        : invoiceNumberLength;
    return '$invoicePrefix${trimmed.substring(0, take).toUpperCase()}';
  }

  static String invoiceFileName(SubscriptionInvoiceEntity invoice) =>
      'floww_invoice_${AppDateUtils.dateKey(invoice.paidAt)}'
      '_${invoiceNumber(invoice.id).toLowerCase()}';

  static String statementFileName(DateTime generatedOn) =>
      'floww_payment_statement_${AppDateUtils.dateKey(generatedOn)}';

  static String billingPeriod(SubscriptionInvoiceEntity invoice) {
    final term = SubscriptionTermFields.fromPlanId(invoice.planId);
    final end = term.periodEndFrom(invoice.paidAt);
    return '${AppDateUtils.monthDayYear(invoice.paidAt)} to '
        '${AppDateUtils.monthDayYear(end)}';
  }

  static String amountLabel(SubscriptionInvoiceEntity invoice) =>
      CurrencyFormatter.withCode(invoice.amount, invoice.currency);

  Future<InvoiceDocument> buildInvoice(
    SubscriptionInvoiceEntity invoice, {
    required PremiumCustomer customer,
  }) async {
    final document = pw.Document(title: invoiceNumber(invoice.id));

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_gutter),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(
              label: 'INVOICE',
              reference: invoiceNumber(invoice.id),
              issuedOn: invoice.paidAt,
            ),
            pw.SizedBox(height: _blockGap),
            _billedTo(customer),
            pw.SizedBox(height: _blockGap),
            _lineItems(invoice),
            pw.SizedBox(height: _blockGap),
            _totalRow(
              label: invoice.isPaid ? 'Total paid' : 'Amount due',
              value: amountLabel(invoice),
            ),
            pw.SizedBox(height: _gap),
            _statusLine(invoice.isPaid),
            pw.Spacer(),
            _footer(isSimulated: invoice.isSimulated),
          ],
        ),
      ),
    );

    return _save(document, invoiceFileName(invoice));
  }

  Future<InvoiceDocument> buildStatement(
    List<SubscriptionInvoiceEntity> invoices, {
    required PremiumCustomer customer,
    DateTime? generatedOn,
  }) async {
    if (invoices.isEmpty) {
      throw InvoicePdfException('There are no invoices to export yet.');
    }

    final issuedOn = generatedOn ?? DateTime.now();
    final ordered = [...invoices]
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    final paid = ordered.where((invoice) => invoice.isPaid).toList();
    final total = paid.fold(0, (sum, invoice) => sum + invoice.amount);
    final currency = ordered.first.currency;
    final since = ordered.last.paidAt;

    final document = pw.Document(title: 'Floww Payment Statement');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_gutter),
        footer: (context) => _pageFooter(context),
        build: (context) => [
          _header(
            label: 'PAYMENT STATEMENT',
            reference:
                '${paid.length} ${paid.length == 1 ? 'payment' : 'payments'}',
            issuedOn: issuedOn,
          ),
          pw.SizedBox(height: _blockGap),
          _billedTo(customer),
          pw.SizedBox(height: _blockGap),
          _summaryBand(
            total: CurrencyFormatter.withCode(total, currency),
            count: paid.length,
            since: since,
          ),
          pw.SizedBox(height: _blockGap),
          _statementTable(ordered),
          pw.SizedBox(height: _blockGap),
          _totalRow(
            label: 'Total paid to date',
            value: CurrencyFormatter.withCode(total, currency),
          ),
          pw.SizedBox(height: _blockGap),
          _footer(
            isSimulated: ordered.any((invoice) => invoice.isSimulated),
          ),
        ],
      ),
    );

    return _save(document, statementFileName(issuedOn));
  }

  Future<InvoiceDocument> _save(pw.Document document, String fileName) async {
    try {
      final bytes = await document.save();
      return InvoiceDocument(bytes: bytes, fileName: fileName);
    } catch (e, stackTrace) {
      debugPrint('invoice pdf failed: $e\n$stackTrace');
      throw InvoicePdfException(
        'Could not create the PDF. Please try again.',
      );
    }
  }

  pw.Widget _header({
    required String label,
    required String reference,
    required DateTime issuedOn,
  }) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                brandName,
                style: pw.TextStyle(
                  fontSize: _titleSize,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                  color: _ink,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                brandTagline,
                style: const pw.TextStyle(
                  fontSize: _captionSize,
                  color: _inkSubtle,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: _headingSize,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                  color: _ink,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                reference,
                style: const pw.TextStyle(
                  fontSize: _bodySize,
                  color: _inkSubtle,
                ),
              ),
              pw.Text(
                'Issued ${AppDateUtils.monthDayYear(issuedOn)}',
                style: const pw.TextStyle(
                  fontSize: _captionSize,
                  color: _inkSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: _gap + 4),
      pw.Container(height: 3, color: _accent),
    ],
  );

  pw.Widget _billedTo(PremiumCustomer customer) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionLabel('Billed to'),
      pw.SizedBox(height: _gap - 2),
      pw.Text(
        customer.displayName,
        style: pw.TextStyle(
          fontSize: _bodySize + 1,
          fontWeight: pw.FontWeight.bold,
          color: _ink,
        ),
      ),
      if (customer.email.isNotEmpty)
        pw.Text(
          customer.email,
          style: const pw.TextStyle(fontSize: _bodySize, color: _inkSubtle),
        ),
      if (customer.uid.isNotEmpty)
        pw.Text(
          'Account ${customer.uid}',
          style: const pw.TextStyle(
            fontSize: _captionSize,
            color: _inkSubtle,
          ),
        ),
    ],
  );

  pw.Widget _lineItems(SubscriptionInvoiceEntity invoice) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionLabel('Details'),
      pw.SizedBox(height: _gap),
      pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(3),
          2: pw.FlexColumnWidth(2),
        },
        children: [
          _tableHeader(const ['Description', 'Billing period', 'Amount']),
          _tableRow([
            'Floww Premium - ${invoice.planLabel}',
            billingPeriod(invoice),
            amountLabel(invoice),
          ]),
          _tableRow([
            'Plan code',
            invoice.planId,
            '',
          ], isQuiet: true),
        ],
      ),
    ],
  );

  pw.Widget _statementTable(List<SubscriptionInvoiceEntity> invoices) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('Payments'),
          pw.SizedBox(height: _gap),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(2.2),
              2: pw.FlexColumnWidth(2.6),
              3: pw.FlexColumnWidth(1.4),
              4: pw.FlexColumnWidth(2),
            },
            children: [
              _tableHeader(const [
                'Date',
                'Invoice',
                'Plan',
                'Status',
                'Amount',
              ]),
              for (final invoice in invoices)
                _tableRow([
                  AppDateUtils.monthDayYear(invoice.paidAt),
                  invoiceNumber(invoice.id),
                  invoice.planLabel,
                  invoice.isPaid ? 'Paid' : 'Due',
                  amountLabel(invoice),
                ]),
            ],
          ),
        ],
      );

  pw.Widget _summaryBand({
    required String total,
    required int count,
    required DateTime since,
  }) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const pw.BoxDecoration(color: _surface),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              total,
              style: pw.TextStyle(
                fontSize: _titleSize - 4,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.Text(
              'Total paid to date',
              style: const pw.TextStyle(
                fontSize: _captionSize,
                color: _inkSubtle,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              '$count ${count == 1 ? 'payment' : 'payments'}',
              style: pw.TextStyle(
                fontSize: _bodySize + 1,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.Text(
              'Since ${AppDateUtils.shortMonthYear(since)}',
              style: const pw.TextStyle(
                fontSize: _captionSize,
                color: _inkSubtle,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  pw.Widget _totalRow({required String label, required String value}) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(height: 1, color: _rule),
          pw.SizedBox(height: _gap + 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: _headingSize - 2,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: _headingSize,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
            ],
          ),
        ],
      );

  pw.Widget _statusLine(bool isPaid) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: pw.BoxDecoration(
          color: isPaid ? _accent : _surface,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(
          isPaid ? 'PAID' : 'DUE',
          style: pw.TextStyle(
            fontSize: _captionSize,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1,
            color: _ink,
          ),
        ),
      ),
    ],
  );

  pw.Widget _footer({required bool isSimulated}) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(height: 1, color: _rule),
      pw.SizedBox(height: _gap),
      if (isSimulated)
        pw.Text(
          'Billing is in test mode. This record was created by a simulated '
          'checkout and no card was charged.',
          style: const pw.TextStyle(
            fontSize: _captionSize,
            color: _inkSubtle,
          ),
        ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Generated by the Floww app. Questions? Reply to your Floww account '
        'email and we will help.',
        style: const pw.TextStyle(fontSize: _captionSize, color: _inkSubtle),
      ),
    ],
  );

  pw.Widget _pageFooter(pw.Context context) => pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Text(
      'Page ${context.pageNumber} of ${context.pagesCount}',
      style: const pw.TextStyle(fontSize: _captionSize, color: _inkSubtle),
    ),
  );

  pw.Widget _sectionLabel(String label) => pw.Text(
    label.toUpperCase(),
    style: pw.TextStyle(
      fontSize: _captionSize,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1.2,
      color: _inkSubtle,
    ),
  );

  pw.TableRow _tableHeader(List<String> cells) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: _surface),
    children: [
      for (final cell in cells)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: pw.Text(
            cell,
            style: pw.TextStyle(
              fontSize: _captionSize,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
        ),
    ],
  );

  pw.TableRow _tableRow(List<String> cells, {bool isQuiet = false}) =>
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _rule)),
        ),
        children: [
          for (final cell in cells)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(
                cell,
                style: pw.TextStyle(
                  fontSize: isQuiet ? _captionSize : _bodySize,
                  color: isQuiet ? _inkSubtle : _ink,
                ),
              ),
            ),
        ],
      );
}
