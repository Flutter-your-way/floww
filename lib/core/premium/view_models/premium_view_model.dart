import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/currency_formatter.dart';
import 'package:floww/config/utils/share/share_service.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/services/invoice_pdf_service.dart';
import 'package:floww/core/premium/services/premium_service.dart';

class PremiumViewModel extends ChangeNotifier {
  PremiumViewModel(
    this._service, [
    this._pdfService = const InvoicePdfService(),
    this._shareService = const ShareService(),
  ]) {
    _subscription = _service.watchSnapshot().listen(
      (snapshot) {
        _snapshot = snapshot;
        _isLoading = false;
        _errorMessage = null;
        _notify();
      },
      onError: (Object error) {
        debugPrint('premium watch failed: $error');
        _isLoading = false;
        _errorMessage = 'Could not load your subscription.';
        _notify();
      },
    );
    _lifecycle = AppLifecycleListener(onResume: _refreshFromStore);
    _refreshFromStore();
  }

  final PremiumService _service;
  late final AppLifecycleListener _lifecycle;
  final InvoicePdfService _pdfService;
  final ShareService _shareService;

  PremiumSnapshot _snapshot = PremiumService.catalog;
  StreamSubscription<PremiumSnapshot>? _subscription;
  PremiumTab _tab = PremiumTab.plan;
  bool _tabReverse = false;
  bool _isLoading = true;
  bool _isCancelling = false;
  bool _isExportingAll = false;
  bool _isSyncing = false;
  bool _awaitingStoreReturn = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _downloadingInvoiceId;
  String? _savedMessage;
  Timer? _savedNoticeTimer;

  String get title => 'Floww Premium';

  bool get isLoading => _isLoading;

  bool get isCancelling => _isCancelling;

  String? get errorMessage => _errorMessage;

  List<PremiumTab> get tabs => PremiumTab.values;

  PremiumTab get selectedTab => _tab;

  bool get tabReverse => _tabReverse;

  String tabLabel(PremiumTab tab) => switch (tab) {
    PremiumTab.plan => 'My Plan',
    PremiumTab.payments => 'Payments & Invoice',
  };

  bool get isPlanTab => _tab == PremiumTab.plan;

  SubscriptionEntity? get subscription => _snapshot.subscription;

  bool get isActive {
    final plan = subscription;
    return plan != null && plan.isActive && plan.hasAccess(DateTime.now());
  }

  bool get hasBillingIssue => subscription?.hasBillingIssue ?? false;

  bool get hasPlan => subscription != null;

  String? get statusBadgeLabel => isActive ? 'PREMIUM ACTIVE' : null;

  String get statusTitle => isActive
      ? "You're a Floww Pro!"
      : (hasPlan ? 'Premium Cancelled' : 'No Active Plan');

  String get statusMessage {
    if (isActive && hasBillingIssue) {
      return 'The App Store could not renew your plan. Update your payment '
          'method in App Store settings to keep Premium.';
    }
    if (isActive) {
      return 'All premium features are unlocked and active on your account.';
    }
    final plan = subscription;
    if (plan != null && plan.hasAccess(DateTime.now())) {
      return 'Auto-renew is off. Your plan stays active until the end of the '
          'current billing period.';
    }
    if (hasPlan) {
      return 'Your plan has ended. Resubscribe to unlock Premium again.';
    }
    return 'Upgrade to unlock WAVE coaching, adaptive plans and analytics.';
  }

  String? get statusActionLabel => isActive ? null : 'Upgrade to Premium';

  String get planSummaryLabel {
    final plan = subscription;
    if (plan == null) return 'Free plan';
    final price = subscriptionPriceLabel;
    if (isActive) {
      return price.isEmpty ? plan.planLabel : '${plan.planLabel} · $price';
    }
    return 'Access until · ${AppDateUtils.monthDayYear(plan.renewsOn)}';
  }

  String get subscriptionPriceLabel {
    final plan = subscription;
    if (plan == null || plan.price <= 0) return '';
    return '${CurrencyFormatter.forCurrency(plan.price, plan.currency)}'
        '${plan.periodLabel}';
  }

  String get featuresTitle =>
      isActive ? 'Your Active Features' : 'Premium Features';

  List<PremiumFeature> get features => _snapshot.features;

  String get renewalLabel {
    final plan = subscription;
    if (plan == null) return '';
    if (!isActive) {
      return 'Ends on · ${AppDateUtils.monthDayYear(plan.renewsOn)}';
    }
    final renews = 'Renews on · ${AppDateUtils.monthDayYear(plan.renewsOn)}';
    final price = subscriptionPriceLabel;
    return price.isEmpty ? renews : '$renews · $price';
  }

  bool get showsRenewal => subscription?.hasAccess(DateTime.now()) ?? false;

  String get cancelLabel => 'Manage Subscription';

  String get cancelTitle => 'Manage Subscription';

  String get cancelMessage {
    final plan = subscription;
    final until = plan == null
        ? 'the end of your billing period'
        : AppDateUtils.monthDayYear(plan.renewsOn);
    return 'Your plan is billed by the App Store, so you can switch plans or '
        'cancel from your App Store subscriptions. If you cancel, you keep '
        'every premium feature until $until.';
  }

  String get cancelConfirmLabel => 'Open App Store';

  String get cancelDismissLabel => 'Keep Premium';

  PremiumPaymentsSummary? get paymentsSummary => _snapshot.paymentsSummary;

  bool get hasPayments => paymentsSummary != null;

  String get _paymentsCurrency =>
      _snapshot.invoices.firstOrNull?.currency ?? '';

  String get totalPaidLabel => CurrencyFormatter.forCurrency(
    paymentsSummary?.totalPaid ?? 0,
    _paymentsCurrency,
  );

  String get totalPaidCaption => 'Total paid to date';

  String get paymentCountLabel {
    final count = paymentsSummary?.paymentCount ?? 0;
    return '$count ${count == 1 ? 'payment' : 'payments'}';
  }

  String get paymentsSinceLabel {
    final since = paymentsSummary?.since;
    return since == null
        ? 'No payments yet'
        : 'Since ${AppDateUtils.shortMonthYear(since)}';
  }

  String get invoicesTitle => 'Payments & Invoice';

  String get emptyPaymentsTitle => 'No payments yet';

  String get emptyPaymentsMessage =>
      'Invoices appear here once you start a Floww Premium plan.';

  List<PremiumInvoiceItem> get invoices => [
    for (final invoice in _snapshot.invoices)
      PremiumInvoiceItem(
        id: invoice.id,
        amountLabel: CurrencyFormatter.forCurrency(
          invoice.amount,
          invoice.currency,
        ),
        subtitle:
            '${invoice.planLabel} · '
            '${AppDateUtils.monthDayYear(invoice.paidAt)}',
        statusLabel: invoice.isSimulated
            ? 'Sandbox'
            : (invoice.isPaid ? 'Paid' : 'Due'),
        actionLabel: 'PDF',
        isDownloading: _downloadingInvoiceId == invoice.id,
      ),
  ];

  String get exportInvoicesLabel => 'Export All Invoices';

  bool get isExportingAll => _isExportingAll;

  bool get isBusyWithPdf => _isExportingAll || _downloadingInvoiceId != null;

  String? get savedMessage => _savedMessage;

  String savedLocationLabel(SavedFileLocation location) => switch (location) {
    SavedFileLocation.downloads => 'Downloads › Floww',
    SavedFileLocation.appFolder when Platform.isAndroid =>
      'the Floww app folder',
    SavedFileLocation.appFolder => 'Files › On My iPhone › Floww',
  };

  Future<bool> downloadInvoice(String invoiceId) async {
    if (isBusyWithPdf) return false;

    final invoice = _snapshot.invoices
        .where((entry) => entry.id == invoiceId)
        .firstOrNull;
    if (invoice == null) {
      _errorMessage = 'That invoice is no longer available.';
      _notify();
      return false;
    }

    _downloadingInvoiceId = invoiceId;
    _errorMessage = null;
    _notify();

    try {
      final document = await _pdfService.buildInvoice(
        invoice,
        customer: _service.customer,
      );
      await _save(document, label: 'Invoice');
      return true;
    } catch (e) {
      _errorMessage = _pdfErrorOf(e);
      return false;
    } finally {
      _downloadingInvoiceId = null;
      _notify();
    }
  }

  Future<bool> exportAllInvoices() async {
    if (isBusyWithPdf) return false;
    if (_snapshot.invoices.isEmpty) {
      _errorMessage = 'There are no invoices to export yet.';
      _notify();
      return false;
    }

    _isExportingAll = true;
    _errorMessage = null;
    _notify();

    try {
      final document = await _pdfService.buildStatement(
        _snapshot.invoices,
        customer: _service.customer,
      );
      await _save(document, label: 'Statement');
      return true;
    } catch (e) {
      _errorMessage = _pdfErrorOf(e);
      return false;
    } finally {
      _isExportingAll = false;
      _notify();
    }
  }

  Future<void> _save(InvoiceDocument document, {required String label}) async {
    final saved = await _shareService.saveFile(
      document.bytes,
      name: document.fileName,
      extension: InvoicePdfService.fileExtension,
      failureMessage: 'Could not save the PDF. Please try again.',
    );
    _showSaved(
      '$label saved to ${savedLocationLabel(saved.location)} · ${saved.name}',
    );

    try {
      await _shareService.openFile(
        saved.path,
        mimeType: InvoicePdfService.mimeType,
      );
    } on ShareException catch (error) {
      _errorMessage = error.message;
    }
  }

  void _showSaved(String message) {
    _savedNoticeTimer?.cancel();
    _savedMessage = message;
    _savedNoticeTimer = Timer(AppMotion.notice, () {
      _savedMessage = null;
      _notify();
    });
  }

  void dismissSavedMessage() {
    if (_savedMessage == null) return;
    _savedNoticeTimer?.cancel();
    _savedMessage = null;
    _notify();
  }

  String _pdfErrorOf(Object error) => switch (error) {
    InvoicePdfException(:final message) => message,
    ShareException(:final message) => message,
    _ => 'Could not create the PDF. Please try again.',
  };

  String get paymentMethodTitle => 'Payment Method';

  bool get _isSandbox => subscription?.isSimulated ?? false;

  String get paymentMethodLabel =>
      _isSandbox ? 'App Store Sandbox' : 'App Store';

  String get paymentMethodExpiryLabel => _isSandbox
      ? 'Test purchase with a sandbox Apple ID · no real charge'
      : 'Billed securely to your Apple ID';

  String get paymentMethodActionLabel => 'Manage';

  Future<void> openManageSubscription() async {
    _awaitingStoreReturn = true;
    final opened = await _service.openManageSubscription();
    if (opened) return;
    _awaitingStoreReturn = false;
    _errorMessage = 'Could not open App Store subscriptions.';
    _notify();
  }

  Future<void> _refreshFromStore() async {
    if (_isSyncing || _service.userId == null) return;
    _isSyncing = true;
    try {
      await _service.sync(
        failureMessage: 'Could not refresh your subscription.',
      );
    } on PremiumException catch (e) {
      if (_awaitingStoreReturn) {
        _errorMessage = e.message;
        _notify();
      }
    } finally {
      _isSyncing = false;
      _awaitingStoreReturn = false;
    }
  }

  void selectTab(PremiumTab tab) {
    if (_tab == tab) return;
    _tabReverse = tab.index < _tab.index;
    _tab = tab;
    _notify();
  }

  Future<bool> cancelSubscription() async {
    if (!hasPlan || _isCancelling) return false;
    _isCancelling = true;
    _errorMessage = null;
    _notify();
    try {
      await openManageSubscription();
      return true;
    } finally {
      _isCancelling = false;
      _notify();
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _savedNoticeTimer?.cancel();
    _subscription?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}
