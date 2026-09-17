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
  StreamSubscription<List<ConnectedAppItem>>? _subscription;
  bool _disposed = false;

  String get title => 'Connected Apps & Devices';

  String get connectLabel => 'Connect';

  String get connectedLabel => 'Connected';

  List<ConnectedAppItem> get apps => List.unmodifiable(_apps);

  Future<void> connect(String id) async {
    final index = _apps.indexWhere((app) => app.id == id);
    if (index < 0 || _apps[index].isConnected) return;
    _apps = List<ConnectedAppItem>.of(_apps)
      ..[index] = _apps[index].copyWith(isConnected: true);
    notifyListeners();
    await _service.setConnected(id, true);
  }

  void _watch() {
    _subscription = _service.watchConnectedApps().listen(
      (apps) {
        _apps = apps;
        notifyListeners();
      },
      onError: (Object error) => debugPrint('connected apps failed: $error'),
    );
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
