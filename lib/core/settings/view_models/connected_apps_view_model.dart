import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class ConnectedAppsViewModel extends ChangeNotifier {
  ConnectedAppsViewModel(this._service)
    : _apps = List<ConnectedAppItem>.of(_service.defaultConnectedApps()) {
    _watch();
  }

  final SettingsService _service;

  List<ConnectedAppItem> _apps;
  final Set<String> _pending = <String>{};
  String? _errorMessage;
  StreamSubscription<List<ConnectedAppItem>>? _subscription;
  bool _disposed = false;

  String get title => 'Connected Apps & Devices';

  String get connectLabel => 'Connect';

  String get connectedLabel => 'Connected';

  String get disconnectLabel => 'Disconnect';

  String get cancelLabel => 'Keep Connected';

  String get disconnectTitle => 'Disconnect this source?';

  String get errorRetryLabel => 'Dismiss';

  String? get errorMessage => _errorMessage;

  List<ConnectedAppItem> get apps => List.unmodifiable(_apps);

  bool isPending(String id) => _pending.contains(id);

  String disconnectMessage(String name) =>
      'Floww will stop syncing recovery and activity data from $name. '
      'You can reconnect at any time.';

  ConnectedAppItem? appById(String id) {
    for (final app in _apps) {
      if (app.id == id) return app;
    }
    return null;
  }

  Future<void> setConnected(String id, bool isConnected) async {
    final index = _apps.indexWhere((app) => app.id == id);
    if (index < 0) return;
    final previous = _apps[index];
    if (previous.isConnected == isConnected || _pending.contains(id)) return;

    _pending.add(id);
    _errorMessage = null;
    _apps = List<ConnectedAppItem>.of(_apps)
      ..[index] = previous.copyWith(isConnected: isConnected);
    notifyListeners();

    final saved = await _service.setConnected(id, isConnected);
    _pending.remove(id);
    if (!saved) {
      final current = _apps.indexWhere((app) => app.id == id);
      if (current >= 0) {
        _apps = List<ConnectedAppItem>.of(_apps)..[current] = previous;
      }
      _errorMessage = isConnected
          ? 'Could not connect ${previous.name}. Check your connection and try again.'
          : 'Could not disconnect ${previous.name}. Check your connection and try again.';
    }
    notifyListeners();
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _watch() {
    _subscription = _service.watchConnectedApps().listen((apps) {
      _apps = [
        for (final app in apps)
          _pending.contains(app.id) ? (appById(app.id) ?? app) : app,
      ];
      notifyListeners();
    }, onError: (Object error) => debugPrint('connected apps failed: $error'));
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
