import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/premium/services/premium_service.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

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

  void runOrUpgrade(PremiumCapability capability, VoidCallback action) {
    if (canUse(capability)) {
      action();
      return;
    }
    openUpgrade();
  }

  void openUpgrade() {
    HapticManager.medium();
    NavigationService.instance.push(AppRouter.premiumUpgrade);
  }

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
  waveCoach(
    requiresPremium: true,
    lockTitle: 'WAVE is a Premium coach',
    lockMessage:
        'Chat with WAVE, get your daily brief, log meals by message and '
        'get plans that adapt to you.',
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
