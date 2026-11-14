import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/premium/services/premium_service.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PremiumAccessProvider extends ChangeNotifier {
  PremiumAccessProvider(this._service);

  static const String _cancelNote = 'Cancel anytime';
  static const Duration _confirmationHold = Duration(minutes: 5);

  final PremiumService _service;

  StreamSubscription<SubscriptionEntity?>? _watch;
  StreamSubscription<String?>? _userWatch;
  SubscriptionEntity? _subscription;
  SubscriptionEntity? _confirmed;
  DateTime? _confirmedAt;
  Completer<void> _resolved = Completer<void>();
  String? _freeTrialLabel;
  bool _isLoading = true;
  bool _disposed = false;

  SubscriptionEntity? get subscription => _subscription;

  bool get isLoading => _isLoading;

  String? get freeTrialLabel => _freeTrialLabel;

  String get trialFootnote {
    final trial = _freeTrialLabel;
    if (trial == null || trial.isEmpty) return _cancelNote;
    return '${trial[0].toUpperCase()}${trial.substring(1)} · $_cancelNote';
  }

  bool get hasAccess => _subscription?.hasAccess(DateTime.now()) ?? false;

  bool get isTrialing => _subscription?.isInTrial(DateTime.now()) ?? false;

  bool get isActive => _subscription?.isActive ?? false;

  bool get isCancelled => _subscription?.isCancelled ?? false;

  SubscriptionTerm? get term => _subscription?.term;

  String? get planId => _subscription?.planId;

  DateTime? get accessUntil => _subscription?.accessUntil;

  int get trialDaysLeft {
    final trialEnd = _subscription?.trialEndsOn;
    if (trialEnd == null) return 0;
    final left = trialEnd.difference(DateTime.now()).inDays;
    return left < 0 ? 0 : left;
  }

  bool canUse(PremiumCapability capability) =>
      !capability.requiresPremium || hasAccess;

  Future<bool> canUseResolved(PremiumCapability capability) async {
    if (!capability.requiresPremium) return true;
    if (_isLoading) await _resolved.future;
    return canUse(capability);
  }

  Future<void> runOrUpgrade(
    PremiumCapability capability,
    VoidCallback action,
  ) async {
    if (await canUseResolved(capability)) {
      action();
      return;
    }
    openUpgrade();
  }

  void apply(SubscriptionEntity subscription) {
    if (!subscription.hasAccess(DateTime.now())) return;
    _confirmed = subscription;
    _confirmedAt = DateTime.now();
    _setSubscription(subscription);
  }

  SubscriptionEntity? _merged(SubscriptionEntity? incoming) {
    final confirmed = _confirmed;
    final confirmedAt = _confirmedAt;
    final now = DateTime.now();
    if (incoming?.hasAccess(now) ?? false) {
      _confirmed = null;
      _confirmedAt = null;
      return incoming;
    }
    if (confirmed == null ||
        confirmedAt == null ||
        confirmed.uid != _service.userId ||
        now.difference(confirmedAt) > _confirmationHold ||
        !confirmed.hasAccess(now)) {
      _confirmed = null;
      _confirmedAt = null;
      return incoming;
    }
    return confirmed;
  }

  void _setSubscription(SubscriptionEntity? subscription) {
    _subscription = subscription;
    _isLoading = false;
    if (!_resolved.isCompleted) _resolved.complete();
    _notify();
  }

  Future<void> _loadFreeTrial() async {
    final offers = await _service.loadOffers();
    _freeTrialLabel = offers
        .map((offer) => offer.freeTrialLabel)
        .nonNulls
        .firstOrNull;
    _notify();
  }

  void openUpgrade() {
    HapticManager.medium();
    NavigationService.instance.push(AppRouter.premiumUpgrade);
  }

  void start() {
    _loadFreeTrial();
    _userWatch?.cancel();
    _userWatch = _service.watchUserId().listen(_service.identify);
    _watch?.cancel();
    _watch = _service.watchSubscription().listen(
      (subscription) => _setSubscription(_merged(subscription)),
      onError: (Object error) {
        debugPrint('premium access watch failed: $error');
        _setSubscription(_merged(null));
      },
    );
  }

  void clear() {
    _watch?.cancel();
    _watch = null;
    _confirmed = null;
    _confirmedAt = null;
    _resolved = Completer<void>();
    _setSubscription(null);
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watch?.cancel();
    _userWatch?.cancel();
    super.dispose();
  }
}

enum PremiumCapability {
  waveMemory(
    requiresPremium: true,
    lockTitle: 'WAVE Memory is Premium',
    lockMessage:
        'WAVE remembers your injuries, schedule and preferences across chats, '
        'reviews your week and edits your plan for you.',
  ),
  aiFoodScan(
    requiresPremium: true,
    lockTitle: 'AI Food Scan is Premium',
    lockMessage:
        'Snap a photo of your meal and WAVE detects the food, portions and '
        'macros for you in seconds.',
  ),
  adaptiveEngine(
    requiresPremium: true,
    lockTitle: 'Adaptive Engine',
    lockMessage:
        'Plans that adjust to your sleep, recovery and missed sessions '
        'every day.',
  ),
  advancedAnalytics(
    requiresPremium: true,
    lockTitle: 'Advanced Analytics',
    lockMessage:
        'Volume trends, habit consistency, personal records and deep '
        'weekly reports.',
  ),
  personalizedRecommendations(
    requiresPremium: true,
    lockTitle: 'Personalized Recommendations',
    lockMessage:
        'WAVE suggestions built from your workouts, meals, habits and '
        'recovery.',
  ),
  multiModeWorkouts(
    requiresPremium: true,
    lockTitle: 'Multi-mode Workouts',
    lockMessage:
        'Unlock Fat Loss, Cardio, Home and Mobility programs alongside '
        'strength training.',
  );

  const PremiumCapability({
    required this.requiresPremium,
    required this.lockTitle,
    required this.lockMessage,
  });

  final bool requiresPremium;
  final String lockTitle;
  final String lockMessage;
}
