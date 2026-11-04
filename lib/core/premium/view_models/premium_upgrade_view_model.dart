import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/utils/formatters/currency_formatter.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/models/store_offer.dart';
import 'package:floww/core/premium/services/premium_service.dart';

class PremiumUpgradeViewModel extends ChangeNotifier {
  PremiumUpgradeViewModel(this._service) {
    loadOffers();
  }

  static const int _monthsPerYear = 12;
  static const int _percent = 100;

  final PremiumService _service;

  SubscriptionTerm _term = SubscriptionTerm.monthly;
  Map<SubscriptionTerm, StoreOffer> _offers = const {};
  bool _isLoadingOffers = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _disposed = false;
  SubscriptionEntity? _purchased;
  String? _errorMessage;
  String? _noticeMessage;

  String get title => 'Upgrade to Premium';

  List<SubscriptionTerm> get terms => SubscriptionTerm.values;

  SubscriptionTerm get selectedTerm => _term;

  PremiumPlan get plan => _service.planFor(_term);

  StoreOffer? get _offer => _offers[_term];

  bool get isLoadingOffers => _isLoadingOffers;

  bool get hasStoreOffers => _offers.isNotEmpty;

  String tabLabel(SubscriptionTerm term) => _service.planFor(term).tabLabel;

  String? tabBadgeLabel(SubscriptionTerm term) {
    if (term != SubscriptionTerm.yearly) return null;
    final percent = _yearlySavingsPercent;
    if (percent == null) return _service.planFor(term).tabBadgeLabel;
    return percent > 0 ? 'Save $percent%' : null;
  }

  int? get _yearlySavingsPercent {
    final monthly = _offers[SubscriptionTerm.monthly]?.price;
    final yearly = _offers[SubscriptionTerm.yearly]?.price;
    if (monthly == null || yearly == null || monthly <= 0) return null;
    final fullYear = monthly * _monthsPerYear;
    return ((fullYear - yearly) / fullYear * _percent).round();
  }

  String get priceLabel =>
      _offer?.priceLabel ?? CurrencyFormatter.rupees(plan.price);

  String get periodLabel => plan.periodLabel;

  String? get highlightLabel => plan.highlightLabel;

  String? get savingsLabel {
    if (_term != SubscriptionTerm.yearly) return null;
    final monthly = _offers[SubscriptionTerm.monthly];
    final yearly = _offers[SubscriptionTerm.yearly];
    if (monthly == null || yearly == null) return _catalogSavingsLabel;

    final savings = monthly.price * _monthsPerYear - yearly.price;
    if (savings <= 0) return null;
    final currency = yearly.currencyCode;
    final monthlyEquivalent = (yearly.price / _monthsPerYear).round();
    return '~${CurrencyFormatter.forCurrency(monthlyEquivalent, currency)}'
        '/month · Save ${CurrencyFormatter.forCurrency(savings.round(), currency)}';
  }

  String? get _catalogSavingsLabel {
    final monthlyEquivalent = plan.monthlyEquivalent;
    final savings = plan.savings;
    if (monthlyEquivalent == null || savings == null) return null;
    return '~${CurrencyFormatter.rupees(monthlyEquivalent)}/month '
        '· Save ${CurrencyFormatter.rupees(savings)}';
  }

  String get planTitle => 'Floww Premium';

  String get planSubtitle => 'The full WAVE experience, unleashed.';

  List<PremiumFeature> get features => PremiumService.features;

  String get ctaLabel {
    final trial = _offer?.freeTrialLabel;
    return trial == null ? plan.ctaLabel : 'Start ${_capitalized(trial)}';
  }

  String get footnoteLabel {
    final offer = _offer;
    if (offer == null) {
      return '${AppSubscription.trialDays}-day free trial · Cancel anytime '
          '· No commitment';
    }
    final renewal = 'Then ${offer.priceLabel}${plan.periodLabel}';
    final trial = offer.freeTrialLabel;
    return [
      if (trial != null) _capitalized(trial),
      renewal,
      'Auto-renews · Cancel anytime in Settings',
    ].join(' · ');
  }

  String get restoreLabel => 'Restore Purchases';

  String get termsLabel => 'Terms of Use';

  String get privacyLabel => 'Privacy Policy';

  Uri get termsUri => Uri.parse(AppSubscription.termsUrl);

  Uri? get privacyUri => AppSubscription.privacyUrl.isEmpty
      ? null
      : Uri.parse(AppSubscription.privacyUrl);

  bool get hasPrivacyLink => privacyUri != null;

  void openTerms() => _service.openLink(termsUri);

  void openPrivacy() {
    final uri = privacyUri;
    if (uri != null) _service.openLink(uri);
  }

  bool get isPurchasing => _isPurchasing;

  bool get isRestoring => _isRestoring;

  bool get isBusy => _isPurchasing || _isRestoring;

  String? get errorMessage => _errorMessage;

  String? get noticeMessage => _noticeMessage;

  SubscriptionEntity? get purchased => _purchased;

  String get successTitle => 'Floww Pro Complete!';

  String get successMessage =>
      'All premium features are unlocked and active on your account.';

  String get successActionLabel => 'Go Active Plan';

  void selectTerm(SubscriptionTerm term) {
    if (_term == term) return;
    _term = term;
    _notify();
  }

  Future<void> loadOffers() async {
    _isLoadingOffers = true;
    _notify();
    final offers = await _service.loadOffers();
    _offers = {
      for (final offer in offers)
        SubscriptionTermFields.fromPlanId(offer.productId): offer,
    };
    _isLoadingOffers = false;
    _notify();
  }

  Future<SubscriptionEntity?> purchase() async {
    if (isBusy) return null;
    _isPurchasing = true;
    _errorMessage = null;
    _noticeMessage = null;
    _notify();

    try {
      _purchased = await _service.subscribe(_term);
      return _purchased;
    } on PremiumException catch (e) {
      if (!e.isCancelled) _errorMessage = e.message;
      return null;
    } finally {
      _isPurchasing = false;
      _notify();
    }
  }

  Future<SubscriptionEntity?> restore() async {
    if (isBusy) return null;
    _isRestoring = true;
    _errorMessage = null;
    _noticeMessage = null;
    _notify();

    try {
      final restored = await _service.restore();
      if (restored != null && restored.hasAccess(DateTime.now())) {
        _purchased = restored;
        return restored;
      }
      _noticeMessage =
          'No active Floww Premium purchase was found for this '
          'Apple ID.';
      return null;
    } on PremiumException catch (e) {
      if (!e.isCancelled) _errorMessage = e.message;
      return null;
    } finally {
      _isRestoring = false;
      _notify();
    }
  }

  void dismissNotice() {
    if (_noticeMessage == null) return;
    _noticeMessage = null;
    _notify();
  }

  String _capitalized(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
