import 'package:floww/config/constants/app_subscription.dart';

enum SubscriptionTerm { monthly, yearly }

enum SubscriptionStatus { none, active, cancelled }

class SubscriptionFields {
  SubscriptionFields._();

  static const String isPremium = 'isPremium';
  static const String planName = 'planName';
  static const String subscription = 'subscription';

  static const String status = 'status';
  static const String term = 'term';
  static const String planId = 'planId';
  static const String price = 'price';
  static const String currency = 'currency';
  static const String periodLabel = 'periodLabel';
  static const String startedAt = 'startedAt';
  static const String renewsOn = 'renewsOn';
  static const String cancelledAt = 'cancelledAt';
  static const String trialEndsOn = 'trialEndsOn';
  static const String updatedAt = 'updatedAt';
  static const String isSimulated = 'isSimulated';
  static const String source = 'source';
  static const String hasBillingIssue = 'hasBillingIssue';
  static const String storeSource = 'revenuecat';

  static String path(String field) => '$subscription.$field';
}

extension SubscriptionTermFields on SubscriptionTerm {
  String get planId => switch (this) {
    SubscriptionTerm.monthly => AppSubscription.monthlyPlanId,
    SubscriptionTerm.yearly => AppSubscription.yearlyPlanId,
  };

  int get durationMonths => switch (this) {
    SubscriptionTerm.monthly => AppSubscription.monthlyDurationMonths,
    SubscriptionTerm.yearly => AppSubscription.yearlyDurationMonths,
  };

  DateTime periodEndFrom(DateTime start) =>
      DateTime(start.year, start.month + durationMonths, start.day);

  static SubscriptionTerm fromPlanId(String planId) =>
      planId.split(':').first == AppSubscription.yearlyPlanId ||
          _yearlyPattern.hasMatch(planId)
      ? SubscriptionTerm.yearly
      : SubscriptionTerm.monthly;

  static final RegExp _yearlyPattern = RegExp(
    'year|annual|12m|p1y',
    caseSensitive: false,
  );
}

class SubscriptionInvoiceEntity {
  const SubscriptionInvoiceEntity({
    required this.id,
    required this.amount,
    required this.planLabel,
    required this.paidAt,
    required this.isPaid,
    required this.isSimulated,
    this.planId = AppSubscription.monthlyPlanId,
    this.currency = '',
  });

  final String id;
  final double amount;
  final String planLabel;
  final DateTime paidAt;
  final bool isPaid;
  final bool isSimulated;
  final String planId;
  final String currency;

  factory SubscriptionInvoiceEntity.fromJson(Map<String, dynamic> json) =>
      SubscriptionInvoiceEntity(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        planLabel: json['planLabel'] as String,
        paidAt: DateTime.parse(json['paidAt'] as String),
        isPaid: json['isPaid'] as bool? ?? true,
        isSimulated: json['isSimulated'] as bool? ?? false,
        planId: json['planId'] as String? ?? AppSubscription.monthlyPlanId,
        currency: json['currency'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'planLabel': planLabel,
    'paidAt': paidAt.toIso8601String(),
    'isPaid': isPaid,
    'isSimulated': isSimulated,
    'planId': planId,
    'currency': currency,
  };
}

class SubscriptionEntity {
  const SubscriptionEntity({
    required this.uid,
    required this.status,
    required this.term,
    required this.price,
    required this.periodLabel,
    required this.planLabel,
    required this.startedAt,
    required this.renewsOn,
    this.cancelledAt,
    required this.isSimulated,
    required this.updatedAt,
    required this.planId,
    this.currency = '',
    this.trialEndsOn,
    this.isStoreManaged = false,
    this.hasBillingIssue = false,
  });

  final String uid;
  final SubscriptionStatus status;
  final SubscriptionTerm term;
  final double price;
  final String periodLabel;
  final String planLabel;
  final DateTime startedAt;
  final DateTime renewsOn;
  final DateTime? cancelledAt;
  final bool isSimulated;
  final DateTime updatedAt;
  final String planId;
  final String currency;
  final DateTime? trialEndsOn;
  final bool isStoreManaged;
  final bool hasBillingIssue;

  bool get isActive => status == SubscriptionStatus.active;

  bool get isCancelled => status == SubscriptionStatus.cancelled;

  bool get isMonthly => term == SubscriptionTerm.monthly;

  bool get isYearly => term == SubscriptionTerm.yearly;

  DateTime get accessUntil => renewsOn;

  bool isInTrial(DateTime now) {
    final trialEnd = trialEndsOn;
    return trialEnd != null && now.isBefore(trialEnd);
  }

  bool hasAccess(DateTime now) =>
      status != SubscriptionStatus.none && now.isBefore(accessUntil);

  bool get isExpired => !hasAccess(DateTime.now());

  static Map<String, dynamic>? sectionOf(Map<String, dynamic>? user) {
    final section = user?[SubscriptionFields.subscription];
    return section is Map ? Map<String, dynamic>.from(section) : null;
  }

  static bool isStoredOn(Map<String, dynamic>? user) {
    final status = sectionOf(user)?[SubscriptionFields.status] as String?;
    return status != null && status != SubscriptionStatus.none.name;
  }

  factory SubscriptionEntity.fromUser(String uid, Map<String, dynamic> user) {
    final section = sectionOf(user) ?? const <String, dynamic>{};
    final term = SubscriptionTerm.values.byName(
      section[SubscriptionFields.term] as String,
    );
    return SubscriptionEntity(
      uid: uid,
      status: SubscriptionStatus.values.byName(
        section[SubscriptionFields.status] as String,
      ),
      term: term,
      price: (section[SubscriptionFields.price] as num? ?? 0).toDouble(),
      periodLabel: section[SubscriptionFields.periodLabel] as String,
      planLabel:
          section[SubscriptionFields.planName] as String? ??
          user[SubscriptionFields.planName] as String,
      startedAt: DateTime.parse(
        section[SubscriptionFields.startedAt] as String,
      ),
      renewsOn: DateTime.parse(section[SubscriptionFields.renewsOn] as String),
      cancelledAt: _dateOf(section[SubscriptionFields.cancelledAt]),
      isSimulated: section[SubscriptionFields.isSimulated] as bool? ?? false,
      updatedAt: DateTime.parse(
        section[SubscriptionFields.updatedAt] as String,
      ),
      planId: section[SubscriptionFields.planId] as String? ?? term.planId,
      currency: section[SubscriptionFields.currency] as String? ?? '',
      trialEndsOn: _dateOf(section[SubscriptionFields.trialEndsOn]),
      isStoreManaged:
          section[SubscriptionFields.source] == SubscriptionFields.storeSource,
      hasBillingIssue:
          section[SubscriptionFields.hasBillingIssue] as bool? ?? false,
    );
  }

  Map<String, dynamic> toUserFields() => {
    SubscriptionFields.isPremium: hasAccess(updatedAt),
    SubscriptionFields.planName: planLabel,
    SubscriptionFields.subscription: toSection(),
  };

  Map<String, dynamic> toSection() => {
    SubscriptionFields.status: status.name,
    SubscriptionFields.term: term.name,
    SubscriptionFields.planId: planId,
    SubscriptionFields.planName: planLabel,
    SubscriptionFields.price: price,
    SubscriptionFields.currency: currency,
    SubscriptionFields.periodLabel: periodLabel,
    SubscriptionFields.startedAt: startedAt.toIso8601String(),
    SubscriptionFields.renewsOn: renewsOn.toIso8601String(),
    SubscriptionFields.cancelledAt: cancelledAt?.toIso8601String(),
    SubscriptionFields.trialEndsOn: trialEndsOn?.toIso8601String(),
    SubscriptionFields.updatedAt: updatedAt.toIso8601String(),
    SubscriptionFields.isSimulated: isSimulated,
  };

  static Map<String, dynamic> cancelledFields(DateTime now) => {
    SubscriptionFields.path(SubscriptionFields.status):
        SubscriptionStatus.cancelled.name,
    SubscriptionFields.path(SubscriptionFields.cancelledAt): now
        .toIso8601String(),
    SubscriptionFields.path(SubscriptionFields.updatedAt): now
        .toIso8601String(),
  };

  static DateTime? _dateOf(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
