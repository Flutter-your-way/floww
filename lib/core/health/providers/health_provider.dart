import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_snapshot.dart';
import '../models/health_vitals.dart';
import '../services/health_log_service.dart';
import '../services/health_service.dart';

enum HealthConnectionStatus { disconnected, connecting, connected, unavailable }

class HealthProvider extends ChangeNotifier {
  HealthProvider(this._service, {HealthLogService? logService})
    : _logService = logService ?? HealthLogService();

  static const String connectedKey = 'health_connected';
  static const String permissionsVersionKey = 'health_permissions_version';

  final HealthService _service;
  final HealthLogService _logService;

  HealthConnectionStatus _status = HealthConnectionStatus.disconnected;
  HealthSnapshot _snapshot = HealthSnapshot.empty;
  HealthVitals _vitals = HealthVitals.empty;
  bool _hasAllPermissions = false;
  bool _isSyncing = false;
  String? _errorMessage;

  HealthConnectionStatus get status => _status;
  HealthSnapshot get snapshot => _snapshot;
  HealthVitals get vitals => _vitals;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;

  bool get isConnected => _status == HealthConnectionStatus.connected;
  bool get isConnecting => _status == HealthConnectionStatus.connecting;
  bool get isUnavailable => _status == HealthConnectionStatus.unavailable;

  bool get hasAllPermissions => isConnected && _hasAllPermissions;

  String get sourceName => HealthService.sourceName;

  bool get usesAppleHealth => HealthService.usesAppleHealth;

  String get sourceIcon =>
      usesAppleHealth ? AppImages.appleHealth : AppImages.healthConnectIcon;

  String get syncSubtitle =>
      'WAVE reads your sleep, steps, heart rate, HRV, VO2 max, blood oxygen '
      'and body measurements from your wearables to adapt each day to you.';

  String? get statusLabel {
    if (isConnecting) return 'Waiting for $sourceName…';
    if (isUnavailable) return 'Not available on this device';
    if (!isConnected) return null;
    if (_isSyncing) return 'Syncing…';
    return _snapshot.summaryLabel;
  }

  Future<void> restore() async {
    if (!await _readPersisted()) return;

    if (!await _service.isSupported()) {
      _status = HealthConnectionStatus.unavailable;
      notifyListeners();
      return;
    }

    _status = HealthConnectionStatus.connected;
    notifyListeners();
    await _upgradePermissions();
    await refresh();
  }

  Future<void> connect() async {
    if (isConnecting) return;

    _errorMessage = null;
    _status = HealthConnectionStatus.connecting;
    notifyListeners();

    try {
      if (await _service.needsHealthConnectInstall()) {
        _status = HealthConnectionStatus.unavailable;
        _errorMessage =
            'Install $sourceName from the Play Store, then tap Connect again.';
        notifyListeners();
        await _service.installHealthConnect();
        return;
      }

      if (!await _service.isSupported()) {
        _status = HealthConnectionStatus.unavailable;
        _errorMessage = 'Health data is not available on this device.';
        notifyListeners();
        return;
      }

      final granted = await _service.requestPermissions();
      if (!granted) {
        _status = HealthConnectionStatus.disconnected;
        _errorMessage =
            '$sourceName access was not granted. You can enable it later in Settings.';
        notifyListeners();
        return;
      }

      _status = HealthConnectionStatus.connected;
      await _persist(true);
      await _persistPermissionsVersion();
      notifyListeners();
      unawaited(refresh());
    } on HealthServiceException catch (e) {
      _status = HealthConnectionStatus.disconnected;
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<bool> requestAllPermissions() async {
    if (!isConnected) {
      await connect();
      return isConnected;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      final granted = await _service.requestPermissions();
      if (!granted) {
        _errorMessage =
            '$sourceName access was not granted. You can enable it later in Settings.';
        notifyListeners();
        return false;
      }
      await _persistPermissionsVersion();
      notifyListeners();
      unawaited(refresh());
      return true;
    } on HealthServiceException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _status = HealthConnectionStatus.disconnected;
    _snapshot = HealthSnapshot.empty;
    _vitals = HealthVitals.empty;
    _hasAllPermissions = false;
    _errorMessage = null;
    await _persist(false);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!isConnected || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      _snapshot = await _service.fetchTodaySnapshot();
      _errorMessage = null;
      unawaited(_logService.saveSnapshot(_snapshot));
      _vitals = await _service.fetchVitals();
    } on HealthServiceException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _upgradePermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(permissionsVersionKey) ?? 1;
      if (version >= HealthService.permissionsVersion) {
        _hasAllPermissions = true;
        notifyListeners();
        return;
      }
      if (!await _service.requestPermissions()) return;
      await prefs.setInt(
        permissionsVersionKey,
        HealthService.permissionsVersion,
      );
      _hasAllPermissions = true;
      notifyListeners();
    } on HealthServiceException catch (e) {
      debugPrint('upgrade health permissions failed: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('upgrade health permissions failed: $e\n$stackTrace');
    }
  }

  Future<void> _persistPermissionsVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        permissionsVersionKey,
        HealthService.permissionsVersion,
      );
      _hasAllPermissions = true;
    } catch (e, stackTrace) {
      debugPrint('persist health permissions version failed: $e\n$stackTrace');
    }
  }

  Future<bool> _readPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(connectedKey) ?? false;
    } catch (e, stackTrace) {
      debugPrint('read health connection flag failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> _persist(bool connected) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(connectedKey, connected);
    } catch (e, stackTrace) {
      debugPrint('persist health connection flag failed: $e\n$stackTrace');
    }
  }
}
