import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_snapshot.dart';
import '../services/health_log_service.dart';
import '../services/health_service.dart';

enum HealthConnectionStatus { disconnected, connecting, connected, unavailable }

class HealthProvider extends ChangeNotifier {
  HealthProvider(this._service, {HealthLogService? logService})
    : _logService = logService ?? HealthLogService();

  static const String connectedKey = 'health_connected';

  final HealthService _service;
  final HealthLogService _logService;

  HealthConnectionStatus _status = HealthConnectionStatus.disconnected;
  HealthSnapshot _snapshot = HealthSnapshot.empty;
  bool _isSyncing = false;
  String? _errorMessage;

  HealthConnectionStatus get status => _status;
  HealthSnapshot get snapshot => _snapshot;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;

  bool get isConnected => _status == HealthConnectionStatus.connected;
  bool get isConnecting => _status == HealthConnectionStatus.connecting;
  bool get isUnavailable => _status == HealthConnectionStatus.unavailable;

  String? get statusLabel {
    if (isConnecting) return 'Waiting for Apple Health…';
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
    await refresh();
  }

  Future<void> connect() async {
    if (isConnecting) return;

    _errorMessage = null;
    _status = HealthConnectionStatus.connecting;
    notifyListeners();

    try {
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
            'Apple Health access was not granted. You can enable it later in Settings.';
        notifyListeners();
        return;
      }

      _status = HealthConnectionStatus.connected;
      await _persist(true);
      notifyListeners();
      await refresh();
    } on HealthServiceException catch (e) {
      _status = HealthConnectionStatus.disconnected;
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _status = HealthConnectionStatus.disconnected;
    _snapshot = HealthSnapshot.empty;
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
      await _logService.saveSnapshot(_snapshot);
    } on HealthServiceException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isSyncing = false;
      notifyListeners();
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
