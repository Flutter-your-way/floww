import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/core/premium/services/premium_service.dart';

class PremiumAccessProvider extends ChangeNotifier {
  PremiumAccessProvider(this._service);

  final PremiumService _service;

  StreamSubscription<SubscriptionEntity?>? _watch;
  SubscriptionEntity? _subscription;
  bool _isLoading = true;
  bool _disposed = false;

  SubscriptionEntity? get subscription => _subscription;

  bool get isLoading => _isLoading;

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

  void start() {
    _watch?.cancel();
    _watch = _service.watchSubscription().listen(
      (subscription) {
        _subscription = subscription;
        _isLoading = false;
        _notify();
      },
      onError: (Object error) {
        debugPrint('premium access watch failed: $error');
        _subscription = null;
        _isLoading = false;
        _notify();
      },
    );
  }

  void clear() {
    _watch?.cancel();
    _watch = null;
    _subscription = null;
    _isLoading = false;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watch?.cancel();
    super.dispose();
  }
}

enum PremiumCapability {
  waveCoach(requiresPremium: true),
  adaptiveEngine(requiresPremium: true),
  personalizedNutrition(requiresPremium: true),
  flowScoreIntelligence(requiresPremium: true),
  advancedAnalytics(requiresPremium: true),
  habitTracking(requiresPremium: false),
  workoutLibrary(requiresPremium: false);

  const PremiumCapability({required this.requiresPremium});

  final bool requiresPremium;
}
