import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/utils/formatters/currency_formatter.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/services/premium_service.dart';

class PremiumUpgradeViewModel extends ChangeNotifier {
  PremiumUpgradeViewModel(this._service);

  final PremiumService _service;

  SubscriptionTerm _term = SubscriptionTerm.monthly;
  bool _isPurchasing = false;
  bool _disposed = false;
  SubscriptionEntity? _purchased;
  String? _errorMessage;

  String get title => 'Upgrade to Premium';

  List<SubscriptionTerm> get terms => SubscriptionTerm.values;

  SubscriptionTerm get selectedTerm => _term;

  PremiumPlan get plan => _service.planFor(_term);

  String tabLabel(SubscriptionTerm term) => _service.planFor(term).tabLabel;

  String? tabBadgeLabel(SubscriptionTerm term) =>
      _service.planFor(term).tabBadgeLabel;

  String get priceLabel => CurrencyFormatter.rupees(plan.price);

  String get periodLabel => plan.periodLabel;

  String? get highlightLabel => plan.highlightLabel;

  String? get savingsLabel {
    final monthlyEquivalent = plan.monthlyEquivalent;
    final savings = plan.savings;
    if (monthlyEquivalent == null || savings == null) return null;

    return '~${CurrencyFormatter.rupees(monthlyEquivalent)}/month '
        '· Save ${CurrencyFormatter.rupees(savings)}';
  }

  String get planTitle => 'Floww Premium';

  String get planSubtitle => 'The full WAVE experience, unleashed.';

  List<PremiumFeature> get features => PremiumService.features;

  String get ctaLabel => plan.ctaLabel;

  String get footnoteLabel =>
      '${AppSubscription.trialDays}-day free trial · Cancel anytime '
      '· No commitment';

  bool get isPurchasing => _isPurchasing;

  String? get errorMessage => _errorMessage;

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

  Future<SubscriptionEntity?> purchase() async {
    if (_isPurchasing) return null;
    _isPurchasing = true;
    _errorMessage = null;
    _notify();

    try {
      _purchased = await _service.subscribe(_term);
      return _purchased;
    } on PremiumException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isPurchasing = false;
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
    super.dispose();
  }
}
