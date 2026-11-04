import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:floww/config/constants/app_subscription.dart';
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
      'The App Store could not complete the purchase. Please try again.';

  bool _configured = false;
  String? _identifiedUid;
  final Map<String, StoreProduct> _products = {};

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
      final products = await Purchases.getProducts(const [
        AppSubscription.monthlyPlanId,
        AppSubscription.yearlyPlanId,
      ]);
      _products
        ..clear()
        ..addEntries(
          products.map((product) => MapEntry(product.identifier, product)),
        );
      return [for (final product in products) _offerOf(product)];
    } catch (e) {
      debugPrint('RevenueCat products failed: $e');
      return const [];
    }
  }

  Future<void> purchase(String productId, {required String uid}) async {
    _requireConfigured();
    await identify(uid);
    var product = _products[productId];
    if (product == null) {
      await loadOffers();
      product = _products[productId];
    }
    if (product == null) {
      throw StorePurchaseException(
        StorePurchaseFailure.unavailable,
        'This plan is not available in the App Store right now.',
      );
    }
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
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

  StoreOffer _offerOf(StoreProduct product) {
    final intro = product.introductoryPrice;
    final hasFreeTrial = intro != null && intro.price == 0;
    return StoreOffer(
      productId: product.identifier,
      price: product.price,
      priceLabel: product.priceString,
      currencyCode: product.currencyCode,
      freeTrialLabel: hasFreeTrial ? _trialLabel(intro) : null,
    );
  }

  String _trialLabel(IntroductoryPrice intro) {
    final count = intro.periodNumberOfUnits * intro.cycles;
    final unit = switch (intro.periodUnit) {
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
