import 'dart:typed_data';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/config/utils/share/share_service.dart';
import 'package:floww/core/premium/services/invoice_pdf_service.dart';
import 'package:floww/core/premium/services/premium_service.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/services/profile_service.dart';

ProfileAccount buildAccount({
  String? name = 'Von Doe',
  double? heightCm = 178,
  double? weightKg = 76,
  MeasurementSystem unitSystem = MeasurementSystem.metric,
  String? goal = 'Lose Fat',
  String? diet = 'Flexible',
  String? experience = 'Intermediate',
  String? trainingType = 'Gym',
  double? stepsTarget = 10000,
  double? sleepTargetHours = 8,
  double? waterTargetLiters = 2.5,
  DateTime? memberSince,
  SubscriptionEntity? subscription,
}) => ProfileAccount(
  name: name,
  heightCm: heightCm,
  weightKg: weightKg,
  unitSystem: unitSystem,
  goal: goal,
  diet: diet,
  experience: experience,
  trainingType: trainingType,
  stepsTarget: stepsTarget,
  sleepTargetHours: sleepTargetHours,
  waterTargetLiters: waterTargetLiters,
  memberSince: memberSince,
  subscription: subscription,
);

SubscriptionEntity buildSubscription({
  SubscriptionStatus status = SubscriptionStatus.active,
  SubscriptionTerm term = SubscriptionTerm.yearly,
  int price = PremiumService.yearlyPrice,
  String periodLabel = '/year',
  String planLabel = 'Yearly Plan',
  DateTime? startedAt,
  DateTime? renewsOn,
  DateTime? trialEndsOn,
}) => SubscriptionEntity(
  uid: 'test-uid',
  status: status,
  term: term,
  price: price,
  periodLabel: periodLabel,
  planLabel: planLabel,
  startedAt: startedAt ?? DateTime(2025, 8, 12),
  renewsOn: renewsOn ?? DateTime(2026, 8, 12),
  isSimulated: true,
  updatedAt: startedAt ?? DateTime(2025, 8, 12),
  planId: term.planId,
  trialEndsOn: trialEndsOn,
);

SubscriptionInvoiceEntity buildInvoice({
  required String id,
  int amount = PremiumService.yearlyPrice,
  String planLabel = 'Yearly Plan',
  String planId = AppSubscription.yearlyPlanId,
  required DateTime paidAt,
}) => SubscriptionInvoiceEntity(
  id: id,
  amount: amount,
  planLabel: planLabel,
  paidAt: paidAt,
  isPaid: true,
  isSimulated: true,
  planId: planId,
);

class FakeProfileService extends ProfileService {
  FakeProfileService({ProfileAccount? account})
    : account = account ?? buildAccount();

  ProfileAccount account;
  PersonalInformationDraft? savedPersonalInformation;
  DailyTargetsDraft? savedDailyTargets;
  MeasurementSystem? savedMeasurementSystem;

  @override
  Stream<ProfileAccount> watchAccount() => Stream.value(account);

  @override
  Future<ProfileAccount> loadAccount() async => account;

  @override
  Future<void> savePersonalInformation(PersonalInformationDraft draft) async {
    savedPersonalInformation = draft;
  }

  @override
  Future<void> saveDailyTargets(DailyTargetsDraft draft) async {
    savedDailyTargets = draft;
  }

  @override
  Future<void> saveMeasurementSystem(MeasurementSystem system) async {
    savedMeasurementSystem = system;
  }
}

class FakeAuthService extends AuthService {
  bool didSignOut = false;

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}

class FakePremiumService extends PremiumService {
  FakePremiumService({this.subscription, this.invoices = const []});

  SubscriptionEntity? subscription;
  List<SubscriptionInvoiceEntity> invoices;
  SubscriptionTerm? subscribedTerm;
  bool didCancel = false;

  @override
  PremiumCustomer get customer => const PremiumCustomer(
    name: 'Von Doe',
    email: 'von@floww.app',
    uid: 'test-uid',
  );

  @override
  Stream<PremiumSnapshot> watchSnapshot() => Stream.value(
    PremiumSnapshot(
      features: PremiumService.features,
      plans: PremiumService.plans,
      subscription: subscription,
      invoices: invoices,
    ),
  );

  @override
  Future<SubscriptionEntity> subscribe(
    SubscriptionTerm term, {
    DateTime? from,
  }) async {
    subscribedTerm = term;
    final plan = planFor(term);
    final start = from ?? DateTime(2026, 1, 12);
    subscription = buildSubscription(
      term: term,
      price: plan.price,
      periodLabel: plan.periodLabel,
      planLabel: plan.planLabel,
      startedAt: start,
      renewsOn: term.periodEndFrom(start),
      trialEndsOn: start.add(const Duration(days: AppSubscription.trialDays)),
    );
    return subscription!;
  }

  @override
  Stream<SubscriptionEntity?> watchSubscription() =>
      Stream.value(subscription);

  @override
  Future<void> cancel() async {
    didCancel = true;
    final current = subscription;
    if (current == null) return;
    subscription = buildSubscription(
      status: SubscriptionStatus.cancelled,
      term: current.term,
      price: current.price,
      periodLabel: current.periodLabel,
      planLabel: current.planLabel,
      startedAt: current.startedAt,
      renewsOn: current.renewsOn,
    );
  }
}

class FakeInvoicePdfService extends InvoicePdfService {
  FakeInvoicePdfService({this.failure});

  final Object? failure;
  SubscriptionInvoiceEntity? builtInvoice;
  List<SubscriptionInvoiceEntity>? builtStatement;
  PremiumCustomer? customer;

  static final Uint8List bytes = Uint8List.fromList([1, 2, 3, 4]);

  @override
  Future<InvoiceDocument> buildInvoice(
    SubscriptionInvoiceEntity invoice, {
    required PremiumCustomer customer,
  }) async {
    if (failure != null) throw failure!;
    builtInvoice = invoice;
    this.customer = customer;
    return InvoiceDocument(bytes: bytes, fileName: 'invoice');
  }

  @override
  Future<InvoiceDocument> buildStatement(
    List<SubscriptionInvoiceEntity> invoices, {
    required PremiumCustomer customer,
    DateTime? generatedOn,
  }) async {
    if (failure != null) throw failure!;
    builtStatement = invoices;
    this.customer = customer;
    return InvoiceDocument(bytes: bytes, fileName: 'statement');
  }
}

class FakeShareService extends ShareService {
  FakeShareService({this.failure});

  final Object? failure;
  final List<String> sharedNames = [];
  String? sharedMimeType;

  @override
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    required String extension,
    required String mimeType,
    String? text,
    String failureMessage = 'Could not prepare your file. Please try again.',
  }) async {
    if (failure != null) throw failure!;
    sharedNames.add('$name$extension');
    sharedMimeType = mimeType;
  }
}
