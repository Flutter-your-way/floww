import 'dart:async';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/core/flow_mode/models/flow_mode_change.dart';
import 'package:flutter/foundation.dart';

class FlowModeController extends ChangeNotifier {
  FlowModeController(this._themeController);

  final ThemeModeController _themeController;

  Timer? _settleTimer;
  Timer? _watchdogTimer;
  FlowModeChange? _activeTransition;
  DateTime? _lastTransitionAt;
  int _transitionCount = 0;
  int? _score;
  bool _hasBaseline = false;
  bool _isAppActive = true;
  bool _disposed = false;

  AppThemeMode get mode => _themeController.mode;

  int? get score => _score;

  FlowModeChange? get activeTransition => _activeTransition;

  bool get isTransitioning => _activeTransition != null;

  void reportScore(int score) {
    if (_disposed) return;
    _score = score;

    final resolved = AppThemeMode.fromFlowScore(score);

    if (!_hasBaseline) {
      _hasBaseline = true;
      _settleTimer?.cancel();
      _applyMode(resolved);
      return;
    }

    if (resolved == mode && !isTransitioning) {
      _settleTimer?.cancel();
      return;
    }

    _scheduleSettle(AppMotion.modeSettleDebounce);
  }

  void setAppActive(bool isActive) {
    if (_disposed || _isAppActive == isActive) return;
    _isAppActive = isActive;
    if (isActive) _scheduleSettle(AppMotion.modeSettleRetry);
  }

  void completeTransition() {
    if (_disposed || _activeTransition == null) return;
    _watchdogTimer?.cancel();
    _activeTransition = null;
    _lastTransitionAt = DateTime.now();
    notifyListeners();
    _scheduleSettle(AppMotion.modeSettleRetry);
  }

  void applyTransitionTheme() {
    final transition = _activeTransition;
    if (transition == null || mode == transition.mode) return;
    _applyMode(transition.mode);
  }

  void debugForceTransition(AppThemeMode target) {
    if (!kDebugMode) return;
    if (_disposed || target == mode || isTransitioning) return;
    _settleTimer?.cancel();
    _begin(target);
  }

  void _scheduleSettle(Duration delay) {
    _settleTimer?.cancel();
    _settleTimer = Timer(delay, _settle);
  }

  void _settle() {
    if (_disposed || !_isAppActive) return;

    final score = _score;
    if (score == null) return;

    if (isTransitioning) {
      _scheduleSettle(AppMotion.modeSettleRetry);
      return;
    }

    final resolved = AppThemeMode.fromFlowScore(score);
    if (resolved == mode) return;

    final remaining = _cooldownRemaining();
    if (remaining > Duration.zero) {
      _scheduleSettle(remaining);
      return;
    }

    _begin(resolved);
  }

  Duration _cooldownRemaining() {
    final last = _lastTransitionAt;
    if (last == null) return Duration.zero;

    final elapsed = DateTime.now().difference(last);
    final remaining = AppMotion.modeTransitionCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _begin(AppThemeMode target) {
    _transitionCount += 1;
    _activeTransition = FlowModeChange(
      previousMode: mode,
      mode: target,
      id: _transitionCount,
    );
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(AppMotion.modeTransitionWatchdog, _recover);
    notifyListeners();
  }

  void _recover() {
    final transition = _activeTransition;
    if (_disposed || transition == null) return;
    _applyMode(transition.mode);
    _activeTransition = null;
    _lastTransitionAt = DateTime.now();
    notifyListeners();
    _scheduleSettle(AppMotion.modeSettleRetry);
  }

  void _applyMode(AppThemeMode target) {
    if (mode == target) return;
    unawaited(_themeController.setMode(target));
  }

  @override
  void dispose() {
    _disposed = true;
    _settleTimer?.cancel();
    _watchdogTimer?.cancel();
    super.dispose();
  }
}
