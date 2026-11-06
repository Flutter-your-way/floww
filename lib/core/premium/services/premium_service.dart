import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/services/app_api_client.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/models/store_offer.dart';
import 'package:floww/core/premium/services/store_purchase_service.dart';

class PremiumException implements Exception {
  PremiumException(this.message, {this.isCancelled = false});

  final String message;
  final bool isCancelled;

  @override
  String toString() => message;
}

class PremiumService {
  PremiumService({AppApiClient? apiClient, StorePurchaseService? store})
    : _apiClient = apiClient ?? AppApiClient(),
      _store = store ?? StorePurchaseService.instance;

  final AppApiClient _apiClient;
  final StorePurchaseService _store;

  static const String paidAtField = 'paidAt';
  static const String _confirmingMessage =
      'Payment received. We are confirming it — tap Restore Purchases '
      'if Premium does not unlock in a minute.';

  static const List<PremiumFeature> features = [
    PremiumFeature(
      icon: Icons.waves_rounded,
      title: 'WAVE AI Coaching',
      description: 'Memory, weekly reviews, plan edits, 60 messages a day',
      tone: PremiumFeatureTone.primary,
    ),
    PremiumFeature(
      icon: Icons.bolt_rounded,
      title: 'Adaptive Engine',
      description: 'Workouts that adjust to your sleep and recovery',
      tone: PremiumFeatureTone.primary,
    ),
    PremiumFeature(
      icon: Icons.photo_camera_rounded,
      title: 'AI Food Scan',
      description: 'Log meals from a photo in seconds',
      tone: PremiumFeatureTone.success,
    ),
    PremiumFeature(
      icon: Icons.auto_awesome_rounded,
      title: 'Personalized Recommendations',
      description: 'Suggested workouts, habits, insights and diet plans',
      tone: PremiumFeatureTone.success,
    ),
    PremiumFeature(
      icon: Icons.insights_rounded,
      title: 'Advanced Analytics',
      description: 'FLOWW Score breakdown, trends, records and reports',
      tone: PremiumFeatureTone.violet,
    ),
    PremiumFeature(
      icon: Icons.fitness_center_rounded,
      title: 'Multi-mode Workouts',
      description: 'Fat Loss, Cardio, Home and Mobility programs',
      tone: PremiumFeatureTone.violet,
    ),
  ];

  static const List<PremiumPlan> plans = [
    PremiumPlan(
      term: SubscriptionTerm.monthly,
      tabLabel: 'Monthly',
      periodLabel: '/month',
      planLabel: 'Monthly Plan',
      ctaLabel: 'Start Monthly Plan',
    ),
    PremiumPlan(
      term: SubscriptionTerm.yearly,
      tabLabel: 'Yearly',
      periodLabel: '/year',
      planLabel: 'Yearly Plan',
      ctaLabel: 'Start Yearly Plan',
      highlightLabel: 'BEST VALUE',
    ),
  ];

  static const PremiumSnapshot catalog = PremiumSnapshot(
    features: features,
    plans: plans,
  );

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  PremiumCustomer get customer {
    final user = _auth.currentUser;
    if (user == null) return PremiumCustomer.empty;
    return PremiumCustomer(
      name: user.displayName ?? '',
      email: user.email ?? '',
      uid: user.uid,
    );
  }

  String get _requireUserId {
    final uid = userId;
    if (uid == null) throw PremiumException('Please sign in again.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppCollection.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _invoices(String uid) =>
      _userDoc(uid).collection(AppCollection.invoices);

  PremiumPlan planFor(SubscriptionTerm term) => catalog.planFor(term);

  Stream<SubscriptionEntity?> watchSubscription() =>
      _auth.authStateChanges().asyncExpand((user) {
        if (user == null) return Stream.value(null);
        return _userDoc(
          user.uid,
        ).snapshots().map((doc) => subscriptionOf(user.uid, doc.data()));
      });

  Stream<PremiumSnapshot> watchSnapshot() {
    final uid = userId;
    if (uid == null) return Stream.value(catalog);

    return combineSnapshot(
      subscription: _userDoc(
        uid,
      ).snapshots().map((doc) => subscriptionOf(uid, doc.data())),
      invoices: _invoices(uid)
          .orderBy(paidAtField, descending: true)
          .snapshots()
          .map((query) => invoicesOf(query.docs.map((doc) => doc.data()))),
    );
  }

  Stream<String?> watchUserId() =>
      _auth.authStateChanges().map((user) => user?.uid);

  Future<void> identify(String? uid) => _store.identify(uid);

  Future<List<StoreOffer>> loadOffers() => _store.loadOffers();

  Future<SubscriptionEntity> subscribe(SubscriptionTerm term) async {
    final uid = _requireUserId;
    try {
      await _store.purchase(term, uid: uid);
    } on StorePurchaseException catch (e) {
      throw PremiumException(e.message, isCancelled: e.isCancelled);
    }
    final subscription = await sync(failureMessage: _confirmingMessage);
    if (subscription == null || !subscription.hasAccess(DateTime.now())) {
      throw PremiumException(_confirmingMessage);
    }
    return subscription;
  }

  Future<SubscriptionEntity?> restore() async {
    final uid = _requireUserId;
    try {
      await _store.restore(uid: uid);
    } on StorePurchaseException catch (e) {
      throw PremiumException(e.message, isCancelled: e.isCancelled);
    }
    return sync(
      failureMessage: 'Could not restore purchases. Please try again.',
    );
  }

  Future<SubscriptionEntity?> sync({required String failureMessage}) async {
    final uid = _requireUserId;
    final data = await _call(
      'syncPremium',
      failureMessage,
      AppApi.syncPremium,
      const {},
    );
    final section = data[SubscriptionFields.subscription];
    if (section is! Map) return null;
    return subscriptionOf(uid, {
      SubscriptionFields.subscription: Map<String, dynamic>.from(section),
    });
  }

  Future<bool> openLink(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('open link failed: $e');
      return false;
    }
  }

  Future<bool> openManageSubscription() async =>
      openLink(await manageSubscriptionUri());

  Future<Uri> manageSubscriptionUri() async =>
      Uri.parse(await _store.manageUrl());

  Future<Map<String, dynamic>> _call(
    String operation,
    String failureMessage,
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      return await _apiClient.post(path, body: body);
    } on AppApiException catch (e) {
      debugPrint('$operation failed: ${e.message}');
      throw PremiumException(
        e.kind == AppApiErrorKind.network ? e.message : failureMessage,
      );
    }
  }

  @visibleForTesting
  static SubscriptionEntity? subscriptionOf(
    String uid,
    Map<String, dynamic>? user,
  ) {
    if (!SubscriptionEntity.isStoredOn(user)) return null;
    try {
      return SubscriptionEntity.fromUser(uid, user!);
    } catch (e) {
      debugPrint('Skipped unreadable subscription: $e');
      return null;
    }
  }

  @visibleForTesting
  static List<SubscriptionInvoiceEntity> invoicesOf(
    Iterable<Map<String, dynamic>> documents,
  ) {
    final invoices = <SubscriptionInvoiceEntity>[];
    for (final json in documents) {
      try {
        invoices.add(SubscriptionInvoiceEntity.fromJson(json));
      } catch (e) {
        debugPrint('Skipped unreadable invoice ${json['id']}: $e');
      }
    }
    return invoices;
  }

  @visibleForTesting
  static Stream<PremiumSnapshot> combineSnapshot({
    required Stream<SubscriptionEntity?> subscription,
    required Stream<List<SubscriptionInvoiceEntity>> invoices,
  }) {
    late final StreamController<PremiumSnapshot> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];
    var pendingSubscription = true;
    var pendingInvoices = true;
    SubscriptionEntity? latestSubscription;
    var latestInvoices = const <SubscriptionInvoiceEntity>[];

    void emit() {
      if (pendingSubscription || pendingInvoices) return;
      controller.add(
        PremiumSnapshot(
          features: features,
          plans: plans,
          subscription: latestSubscription,
          invoices: latestInvoices,
        ),
      );
    }

    controller = StreamController<PremiumSnapshot>(
      onListen: () {
        subscriptions.add(
          subscription.listen((value) {
            latestSubscription = value;
            pendingSubscription = false;
            emit();
          }, onError: controller.addError),
        );
        subscriptions.add(
          invoices.listen((value) {
            latestInvoices = value;
            pendingInvoices = false;
            emit();
          }, onError: controller.addError),
        );
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }
}
