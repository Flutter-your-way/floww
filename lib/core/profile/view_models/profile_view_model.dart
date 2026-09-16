import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/measurement_converter.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/models/profile_view_data.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/navigation/app_router.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._service, this._authService) {
    _subscription = _service.watchAccount().listen(
      (account) {
        _account = account;
        _isLoading = false;
        _errorMessage = null;
        _notify();
      },
      onError: (Object error) {
        debugPrint('profile watch failed: $error');
        _isLoading = false;
        _errorMessage = 'Could not load your profile.';
        _notify();
      },
    );
  }

  static const String _emptyValue = '—';

  final ProfileService _service;
  final AuthService _authService;

  ProfileAccount _account = ProfileAccount.empty;
  StreamSubscription<ProfileAccount>? _subscription;
  bool _isLoading = true;
  bool _isSigningOut = false;
  bool _disposed = false;
  String? _errorMessage;

  String get title => 'My Profile';

  bool get isLoading => _isLoading;

  bool get isSigningOut => _isSigningOut;

  String? get errorMessage => _errorMessage;

  ProfileAccount get account => _account;

  ProfileSummary get summary => ProfileSummary(
    initial: _initial,
    name: _account.name ?? 'Your Profile',
    subtitle: _identitySubtitle,
    isPremium: _account.isPremium,
    avatarUrl: _account.avatarUrl,
  );

  ProfileMetricSection get personalInformation => ProfileMetricSection(
    title: 'Personal Information',
    actionLabel: 'Edit',
    items: [
      ProfileMetricItem(
        icon: Icons.straighten_rounded,
        label: 'Height',
        value: _heightValue,
        unit: _account.heightCm == null ? null : _heightUnitLabel,
      ),
      ProfileMetricItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Weight',
        value: _weightValue,
        unit: _account.weightKg == null ? null : _weightUnitLabel,
      ),
      ProfileMetricItem(
        icon: Icons.person_outline_rounded,
        label: 'Diet',
        value: _account.diet ?? _emptyValue,
      ),
    ],
  );

  ProfileMetricSection get dailyTargets => ProfileMetricSection(
    title: 'Daily Targets',
    actionLabel: 'Edit',
    items: [
      ProfileMetricItem(
        icon: Icons.directions_walk_rounded,
        label: 'Steps',
        value: _account.stepsTarget == null
            ? _emptyValue
            : NumberFormatter.grouped(_account.stepsTarget!.round()),
        unit: _account.stepsTarget == null ? null : 'steps',
      ),
      ProfileMetricItem(
        icon: Icons.bedtime_outlined,
        label: 'Sleep',
        value: _decimal(_account.sleepTargetHours),
        unit: _account.sleepTargetHours == null ? null : 'hours',
      ),
      ProfileMetricItem(
        icon: Icons.water_drop_outlined,
        label: 'Water',
        value: _decimal(_account.waterTargetLiters),
        unit: _account.waterTargetLiters == null ? null : 'liters',
      ),
    ],
  );

  ProfileSubscription get subscription {
    final plan = _account.subscription;

    if (plan != null && plan.isActive) {
      return ProfileSubscription(
        title: 'FLOWW PREMIUM',
        message:
            'All features unlocked · Renews '
            '${AppDateUtils.shortMonthYear(plan.renewsOn)}',
        actionLabel: 'Manage',
        isActive: true,
        hasPlan: true,
        badgeLabel: 'ACTIVE',
      );
    }

    if (plan != null && plan.isCancelled) {
      return ProfileSubscription(
        title: 'FLOWW PREMIUM',
        message:
            'Cancelled · Access until '
            '${AppDateUtils.monthDayYear(plan.renewsOn)}',
        actionLabel: 'Resume Premium',
        isActive: false,
        hasPlan: true,
      );
    }

    final trialDaysLeft = _trialDaysLeft;

    return ProfileSubscription(
      title: 'FLOWW PREMIUM',
      message: trialDaysLeft > 0
          ? 'Free trial active · $trialDaysLeft '
                '${trialDaysLeft == 1 ? 'day' : 'days'} remaining'
          : 'Free plan · Unlock the full WAVE experience',
      actionLabel: 'Upgrade to Premium',
      isActive: false,
      hasPlan: false,
    );
  }

  String get subscriptionRoute =>
      subscription.hasPlan ? AppRouter.premium : AppRouter.premiumUpgrade;

  String get settingsTitle => 'Settings';

  List<ProfileSettingItem> get settings => [
    const ProfileSettingItem(
      icon: Icons.link,
      title: 'Connected Apps & Devices',
      subtitle: 'Sync recovery & activity automatically.',
      route: AppRouter.connectedApps,
    ),
    const ProfileSettingItem(
      icon: Icons.notifications_none_rounded,
      title: 'Notifications',
      subtitle: 'Workout, habit & sleep reminders',
      route: AppRouter.notificationSettings,
    ),
    ProfileSettingItem(
      icon: Icons.language_rounded,
      title: 'Units',
      subtitle: 'Currently: $_unitSystemLabel',
      route: AppRouter.units,
    ),
    const ProfileSettingItem(
      icon: Icons.shield_outlined,
      title: 'Privacy & Data',
      subtitle: 'Export data · Delete account',
      route: AppRouter.privacyData,
    ),
  ];

  String get premiumBadgeLabel => 'PREMIUM';

  String get logOutLabel => 'Log Out';

  String get logOutTitle => 'Log out?';

  String get logOutMessage =>
      'You will need to sign in again to reach your plan, workouts and WAVE.';

  String get cancelLabel => 'Cancel';

  String get versionLabel => 'Floww · v1.0';

  Future<bool> logOut() async {
    if (_isSigningOut) return false;
    _isSigningOut = true;
    _errorMessage = null;
    _notify();

    try {
      await _authService.signOut();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSigningOut = false;
      _notify();
    }
  }

  String get _initial {
    final name = _account.name?.trim();
    if (name == null || name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  String get _identitySubtitle {
    final parts = [
      _account.goal,
      _account.experience,
    ].whereType<String>().toList();
    return parts.isEmpty ? 'Complete your onboarding' : parts.join(' · ');
  }

  bool get _isImperial => _account.unitSystem == MeasurementSystem.imperial;

  String get _heightUnitLabel => _isImperial ? 'in' : 'cm';

  String get _weightUnitLabel => _isImperial ? 'lbs' : 'kg';

  String get _unitSystemLabel => _isImperial
      ? '${MeasurementSystem.imperial.label} (lbs, in)'
      : '${MeasurementSystem.metric.label} (kg, cm)';

  String get _heightValue {
    final heightCm = _account.heightCm;
    if (heightCm == null) return _emptyValue;
    return MeasurementConverter.trimmed(
      _isImperial ? MeasurementConverter.cmToInches(heightCm) : heightCm,
    );
  }

  String get _weightValue {
    final weightKg = _account.weightKg;
    if (weightKg == null) return _emptyValue;
    return MeasurementConverter.trimmed(
      _isImperial ? MeasurementConverter.kgToLbs(weightKg) : weightKg,
    );
  }

  int get _trialDaysLeft {
    final memberSince = _account.memberSince;
    if (memberSince == null) return 0;
    final endsOn = AppDateUtils.addDays(memberSince, AppSubscription.trialDays);
    final daysLeft = AppDateUtils.daysBetween(DateTime.now(), endsOn);
    return daysLeft < 0 ? 0 : daysLeft;
  }

  String _decimal(double? value) =>
      value == null ? _emptyValue : MeasurementConverter.trimmed(value);

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
