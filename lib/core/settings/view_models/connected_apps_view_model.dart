import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class ConnectedAppsViewModel extends ChangeNotifier {
  ConnectedAppsViewModel(this._service)
    : _apps = List<ConnectedAppItem>.of(_service.connectedApps());

  final SettingsService _service;

  List<ConnectedAppItem> _apps;

  String get title => 'Connected Apps & Devices';

  String get connectLabel => 'Connect';

  String get connectedLabel => 'Connected';

  List<ConnectedAppItem> get apps => List.unmodifiable(_apps);

  void connect(String id) {
    final index = _apps.indexWhere((app) => app.id == id);
    if (index < 0 || _apps[index].isConnected) return;
    _apps = List<ConnectedAppItem>.of(_apps)
      ..[index] = _apps[index].copyWith(isConnected: true);
    notifyListeners();
  }

  void refresh() {
    _apps = List<ConnectedAppItem>.of(_service.connectedApps());
    notifyListeners();
  }
}
