import 'package:flutter/widgets.dart';

import 'package:floww/config/entities/subscription_entity.dart';

export 'package:floww/config/entities/subscription_entity.dart';
export 'package:floww/core/premium/models/premium_customer.dart';

enum PremiumTab { plan, payments }

enum PremiumFeatureTone { primary, success, violet }

class PremiumFeature {
  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String description;
  final PremiumFeatureTone tone;
}

class PremiumPlan {
  const PremiumPlan({
    required this.term,
    required this.tabLabel,
    required this.price,
    required this.periodLabel,
    required this.planLabel,
    required this.ctaLabel,
    this.tabBadgeLabel,
    this.highlightLabel,
    this.monthlyEquivalent,
    this.savings,
  });

  final SubscriptionTerm term;

  String get planId => term.planId;

  final String tabLabel;
  final int price;
  final String periodLabel;
  final String planLabel;
  final String ctaLabel;
  final String? tabBadgeLabel;
  final String? highlightLabel;
  final int? monthlyEquivalent;
  final int? savings;
}

class PremiumInvoiceItem {
  const PremiumInvoiceItem({
    required this.id,
    required this.amountLabel,
    required this.subtitle,
    required this.statusLabel,
    required this.actionLabel,
    this.isDownloading = false,
  });

  final String id;
  final String amountLabel;
  final String subtitle;
  final String statusLabel;
  final String actionLabel;
  final bool isDownloading;
}

class PremiumPaymentsSummary {
  const PremiumPaymentsSummary({
    required this.totalPaid,
    required this.paymentCount,
    required this.since,
  });

  final int totalPaid;
  final int paymentCount;
  final DateTime since;
}

class PremiumSnapshot {
  const PremiumSnapshot({
    required this.features,
    required this.plans,
    this.subscription,
    this.invoices = const [],
  });

  final List<PremiumFeature> features;
  final List<PremiumPlan> plans;
  final SubscriptionEntity? subscription;
  final List<SubscriptionInvoiceEntity> invoices;

  PremiumPlan planFor(SubscriptionTerm term) =>
      plans.firstWhere((plan) => plan.term == term);

  PremiumPaymentsSummary? get paymentsSummary {
    if (invoices.isEmpty) return null;
    final paid = invoices.where((invoice) => invoice.isPaid).toList();
    if (paid.isEmpty) return null;

    return PremiumPaymentsSummary(
      totalPaid: paid.fold(0, (total, invoice) => total + invoice.amount),
      paymentCount: paid.length,
      since: paid
          .map((invoice) => invoice.paidAt)
          .reduce((a, b) => a.isBefore(b) ? a : b),
    );
  }

  PremiumSnapshot copyWith({
    SubscriptionEntity? subscription,
    List<SubscriptionInvoiceEntity>? invoices,
  }) => PremiumSnapshot(
    features: features,
    plans: plans,
    subscription: subscription ?? this.subscription,
    invoices: invoices ?? this.invoices,
  );
}
