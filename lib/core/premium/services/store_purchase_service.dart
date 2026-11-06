import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/core/premium/models/store_offer.dart';

enum StorePurchaseFailure { cancelled, pending, unavailable, failed }

class StorePurchaseException implements Exception {
  StorePurchaseException(this.failure, this.message);

  final StorePurchaseFailure failure;
  final String message;

  bool get isCancelled => failure == StorePurchaseFailure.cancelled;

  @override
  String toString() => message;
}

class StorePurchaseService {
  StorePurchaseService._();

  static final StorePurchaseService instance = StorePurchaseService._();

  static const String _unavailableMessage =
      'Purchases are not available on this device yet.';
  static const String _failedMessage =
      'The store could not complete the purchase. Please try again.';

  bool _configured = false;
  String? _identifiedUid;
  static const String _monthlyPeriod = 'P1M';
  static const String _yearlyPeriod = 'P1Y';
  static const String _androidPlanSeparator = ':';

  final Map<SubscriptionTerm, Package> _packages = {};
  final Map<SubscriptionTerm, StoreProduct> _products = {};

  bool get isConfigured => _configured;

  String get _apiKey {
    if (kIsWeb) return '';
    if (Platform.isIOS || Platform.isMacOS) {
      return AppSubscription.revenueCatAppleKey;
    }
    if (Platform.isAndroid) return AppSubscription.revenueCatGoogleKey;
    return '';
  }

  String get fallbackManageUrl => !kIsWeb && Platform.isAndroid
      ? AppSubscription.googleManageUrl
      : AppSubscription.appleManageUrl;

  Future<void> configure({String? uid}) async {
    if (_configured) return;
    final key = _apiKey;
    if (key.isEmpty) {
      debugPrint('RevenueCat key missing; purchases disabled.');
      return;
    }
    try {
      if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
      final configuration = PurchasesConfiguration(key)..appUserID = uid;
      await Purchases.configure(configuration);
      _configured = true;
      _identifiedUid = uid;
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }

  Future<void> identify(String? uid) async {
    if (!_configured || uid == _identifiedUid) return;
    try {
      if (uid == null) {
        if (!await Purchases.isAnonymous) await Purchases.logOut();
      } else {
        await Purchases.logIn(uid);
      }
      _identifiedUid = uid;
    } catch (e) {
      debugPrint('RevenueCat identify failed: $e');
    }
  }

  Future<List<StoreOffer>> loadOffers() async {
    if (!_configured) return const [];
    try {
      final packages = await _offeringPackages();
      _packages
        ..clear()
        ..addAll(packages);
      _products
        ..clear()
        ..addAll({
          for (final entry in packages.entries)
            entry.key: entry.value.storeProduct,
        });
      if (_products.length < SubscriptionTerm.values.length) {
        await _loadFallbackProducts();
      }
      return [
        for (final term in SubscriptionTerm.values)
          if (_products[term] case final product?) _offerOf(term, product),
      ];
    } catch (e) {
      debugPrint('RevenueCat offerings failed: $e');
      return const [];
    }
  }

  Future<Map<SubscriptionTerm, Package>> _offeringPackages() async {
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) {
      debugPrint('RevenueCat has no current offering configured.');
      return const {};
    }
    final packages = <SubscriptionTerm, Package>{
      SubscriptionTerm.monthly: ?offering.monthly,
      SubscriptionTerm.yearly: ?offering.annual,
    };
    for (final package in offering.availablePackages) {
      final term = _termOfProduct(package.storeProduct);
      if (term != null) packages.putIfAbsent(term, () => package);
    }
    return packages;
  }

  Future<void> _loadFallbackProducts() async {
    final missing = [
      for (final term in SubscriptionTerm.values)
        if (!_products.containsKey(term)) term.planId,
    ];
    final products = await Purchases.getProducts(missing);
    for (final product in products) {
      final term = _termOfProduct(product);
      if (term != null) _products.putIfAbsent(term, () => product);
    }
    final stillMissing = SubscriptionTerm.values.where(
      (term) => !_products.containsKey(term),
    );
    if (stillMissing.isNotEmpty) {
      debugPrint(
        'Store returned no product for ${stillMissing.map((t) => t.name).join(', ')}.',
      );
    }
  }

  SubscriptionTerm? _termOfProduct(StoreProduct product) {
    final period = product.subscriptionPeriod;
    if (period == _monthlyPeriod) return SubscriptionTerm.monthly;
    if (period == _yearlyPeriod) return SubscriptionTerm.yearly;
    final baseId = product.identifier.split(_androidPlanSeparator).first;
    for (final term in SubscriptionTerm.values) {
      if (baseId == term.planId) return term;
    }
    return null;
  }

  Future<void> purchase(SubscriptionTerm term, {required String uid}) async {
    _requireConfigured();
    await identify(uid);
    if (!_products.containsKey(term)) await loadOffers();
    final package = _packages[term];
    final product = _products[term];
    if (package == null && product == null) {
      throw StorePurchaseException(
        StorePurchaseFailure.unavailable,
        'This plan is not available in the store right now.',
      );
    }
    try {
      await Purchases.purchase(
        package != null
            ? PurchaseParams.package(package)
            : PurchaseParams.storeProduct(product!),
      );
    } on PlatformException catch (e) {
      throw _exceptionOf(e);
    }
  }

  Future<bool> restore({required String uid}) async {
    _requireConfigured();
    await identify(uid);
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(
        AppSubscription.entitlementId,
      );
    } on PlatformException catch (e) {
      throw _exceptionOf(e);
    }
  }

  Future<String> manageUrl() async {
    if (!_configured) return fallbackManageUrl;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.managementURL ?? fallbackManageUrl;
    } catch (e) {
      debugPrint('RevenueCat customer info failed: $e');
      return fallbackManageUrl;
    }
  }

  void _requireConfigured() {
    if (_configured) return;
    throw StorePurchaseException(
      StorePurchaseFailure.unavailable,
      _unavailableMessage,
    );
  }

  StoreOffer _offerOf(SubscriptionTerm term, StoreProduct product) =>
      StoreOffer(
        term: term,
        productId: product.identifier,
        price: product.price,
        priceLabel: product.priceString,
        currencyCode: product.currencyCode,
        freeTrialLabel: _freeTrialOf(product),
      );

  String? _freeTrialOf(StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro != null && intro.price == 0) {
      return _trialLabel(
        intro.periodNumberOfUnits * intro.cycles,
        intro.periodUnit,
      );
    }
    final period = product.defaultOption?.freePhase?.billingPeriod;
    if (period == null) return null;
    final cycles = product.defaultOption?.freePhase?.billingCycleCount ?? 1;
    return _trialLabel(period.value * cycles, period.unit);
  }

  String _trialLabel(int count, PeriodUnit periodUnit) {
    final unit = switch (periodUnit) {
      PeriodUnit.day => 'day',
      PeriodUnit.week => 'week',
      PeriodUnit.month => 'month',
      PeriodUnit.year => 'year',
      PeriodUnit.unknown => 'day',
    };
    return '$count-$unit free trial';
  }

  StorePurchaseException _exceptionOf(PlatformException error) {
    final code = PurchasesErrorHelper.getErrorCode(error);
    debugPrint('RevenueCat purchase error: $code ${error.message}');
    return switch (code) {
      PurchasesErrorCode.purchaseCancelledError => StorePurchaseException(
        StorePurchaseFailure.cancelled,
        'Purchase cancelled.',
      ),
      PurchasesErrorCode.paymentPendingError => StorePurchaseException(
        StorePurchaseFailure.pending,
        'Your payment is pending approval. Premium unlocks once it clears.',
      ),
      PurchasesErrorCode.purchaseNotAllowedError ||
      PurchasesErrorCode.storeProblemError ||
      PurchasesErrorCode.configurationError ||
      PurchasesErrorCode.productNotAvailableForPurchaseError =>
        StorePurchaseException(
          StorePurchaseFailure.unavailable,
          _unavailableMessage,
        ),
      PurchasesErrorCode.networkError => StorePurchaseException(
        StorePurchaseFailure.failed,
        'No connection. Check your internet and try again.',
      ),
      _ => StorePurchaseException(StorePurchaseFailure.failed, _failedMessage),
    };
  }
}
