import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';

class PremiumException implements Exception {
  PremiumException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PremiumService {
  PremiumService();

  static const int monthlyPrice = AppSubscription.monthlyPrice;
  static const int yearlyPrice = AppSubscription.yearlyPrice;
  static const String paidAtField = 'paidAt';

  static const List<PremiumFeature> features = [
    PremiumFeature(
      icon: Icons.waves_rounded,
      title: 'WAVE AI Coach',
      description: 'Full AI coaching, logging, and motivation',
      tone: PremiumFeatureTone.primary,
    ),
    PremiumFeature(
      icon: Icons.bolt_rounded,
      title: 'Adaptive Engine',
      description: 'Plans that evolve with your recovery daily',
      tone: PremiumFeatureTone.primary,
    ),
    PremiumFeature(
      icon: Icons.local_fire_department_rounded,
      title: 'Personalized Nutrition',
      description: 'Macro targets tailored to your goals daily',
      tone: PremiumFeatureTone.success,
    ),
    PremiumFeature(
      icon: Icons.monitor_heart_rounded,
      title: 'Flow Score Intelligence',
      description: 'Real-time readiness & performance scoring',
      tone: PremiumFeatureTone.primary,
    ),
    PremiumFeature(
      icon: Icons.star_outline_rounded,
      title: 'Advanced Analytics',
      description: 'Deep progress insights and trend reports',
      tone: PremiumFeatureTone.violet,
    ),
  ];

  static const List<PremiumPlan> plans = [
    PremiumPlan(
      term: SubscriptionTerm.monthly,
      tabLabel: 'Monthly',
      price: monthlyPrice,
      periodLabel: '/month',
      planLabel: 'Monthly Plan',
      ctaLabel: 'Start Monthly Plan',
    ),
    PremiumPlan(
      term: SubscriptionTerm.yearly,
      tabLabel: 'Yearly',
      price: yearlyPrice,
      periodLabel: '/year',
      planLabel: 'Yearly Plan',
      ctaLabel: 'Start Yearly Plan',
      tabBadgeLabel: 'Save 33%',
      highlightLabel: 'BEST VALUE',
      monthlyEquivalent: yearlyPrice ~/ 12,
      savings: monthlyPrice * 12 - yearlyPrice,
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

  Future<SubscriptionEntity> subscribe(
    SubscriptionTerm term, {
    DateTime? from,
  }) async {
    final uid = _requireUserId;
    final plan = planFor(term);
    final start = from ?? DateTime.now();

    final subscription = SubscriptionEntity(
      uid: uid,
      status: SubscriptionStatus.active,
      term: term,
      price: plan.price,
      periodLabel: plan.periodLabel,
      planLabel: plan.planLabel,
      startedAt: start,
      renewsOn: term.periodEndFrom(start),
      isSimulated: true,
      updatedAt: start,
      planId: plan.planId,
      trialEndsOn: start.add(const Duration(days: AppSubscription.trialDays)),
    );

    await _write('subscribe', 'Could not start your plan. Please try again.', () {
      final invoiceDoc = _invoices(uid).doc();
      final invoice = SubscriptionInvoiceEntity(
        id: invoiceDoc.id,
        amount: plan.price,
        planLabel: plan.planLabel,
        paidAt: start,
        isPaid: true,
        isSimulated: true,
        planId: plan.planId,
      );

      final batch = _firestore.batch();
      batch.set(
        _userDoc(uid),
        subscription.toUserFields(),
        SetOptions(merge: true),
      );
      batch.set(invoiceDoc, invoice.toJson());
      return batch.commit();
    });

    return subscription;
  }

  Future<void> cancel() async {
    final uid = _requireUserId;
    final now = DateTime.now();

    await _write('cancel', 'Could not cancel your plan. Please try again.', () {
      return _userDoc(uid).update(SubscriptionEntity.cancelledFields(now));
    });
  }

  Future<void> _write(
    String operation,
    String failureMessage,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on PremiumException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw PremiumException(failureMessage);
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
