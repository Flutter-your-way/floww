import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_integrations.dart';
import 'package:floww/config/services/app_api_client.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';
import 'package:floww/core/settings/services/wearable_service.dart';

class ConnectedAppsViewModel extends ChangeNotifier {
  ConnectedAppsViewModel(this._service, this._wearables, this._health)
    : _stored = List<ConnectedAppItem>.of(_service.defaultConnectedApps()) {
    _health.addListener(_onHealthChanged);
    _watch();
    if (AppIntegrations.cloudEnabled) unawaited(_wearables.sync());
  }

  final SettingsService _service;
  final WearableService _wearables;
  final HealthProvider _health;

  List<ConnectedAppItem> _stored;
  final Set<String> _pending = <String>{};
  final Set<String> _awaitingAuthorization = <String>{};
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

  List<ConnectedAppItem> get apps => List.unmodifiable(
    _stored
        .where((app) => !app.isOnDevice || _supportsOnDevice(app))
        .map(_resolve),
  );

  bool isEnabled(String id) =>
      AppIntegrations.cloudEnabled || (appById(id)?.isOnDevice ?? false);

  bool isPending(String id) {
    final app = appById(id);
    if (app != null && app.isOnDevice && _supportsOnDevice(app)) {
      return _health.isConnecting;
    }
    return _pending.contains(id);
  }

  String disconnectMessage(String name) =>
      'Floww will stop syncing recovery and activity data from $name. '
      'You can reconnect at any time.';

  ConnectedAppItem? appById(String id) {
    for (final app in _stored) {
      if (app.id == id) return _resolve(app);
    }
    return null;
  }

  Future<void> setConnected(String id, bool isConnected) async {
    final app = appById(id);
    if (app == null ||
        !isEnabled(id) ||
        app.isConnected == isConnected ||
        isPending(id)) {
      return;
    }

    _errorMessage = null;
    if (app.isOnDevice) {
      await _setOnDeviceConnected(app, isConnected);
    } else if (isConnected) {
      await _connectCloud(app);
    } else {
      await _disconnectCloud(app);
    }
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  ConnectedAppItem _resolve(ConnectedAppItem app) {
    if (!app.isOnDevice) {
      return AppIntegrations.cloudEnabled
          ? app
          : app.copyWith(isConnected: false);
    }
    return app.copyWith(
      isConnected: _supportsOnDevice(app) && _health.isConnected,
    );
  }

  bool _supportsOnDevice(ConnectedAppItem app) => switch (app.kind) {
    ConnectedAppKind.appleHealth => Platform.isIOS,
    ConnectedAppKind.healthConnect => Platform.isAndroid,
    ConnectedAppKind.cloud => false,
  };

  String _unsupportedMessage(ConnectedAppItem app) =>
      app.kind == ConnectedAppKind.appleHealth
      ? '${app.name} is only available on iPhone.'
      : '${app.name} is only available on Android.';

  Future<void> _setOnDeviceConnected(
    ConnectedAppItem app,
    bool isConnected,
  ) async {
    if (!_supportsOnDevice(app)) {
      _errorMessage = _unsupportedMessage(app);
      notifyListeners();
      return;
    }

    if (isConnected) {
      await _health.connect();
      if (!_health.isConnected) {
        _errorMessage = _health.errorMessage;
        notifyListeners();
        return;
      }
    } else {
      await _health.disconnect();
    }
    await _service.setConnected(app.id, isConnected);
  }

  Future<void> _connectCloud(ConnectedAppItem app) async {
    _setPending(app.id, true);
    try {
      final url = await _wearables.authorizationUrl(app.id);
      final opened = await _wearables.openAuthorization(url);
      if (opened) {
        _awaitingAuthorization.add(app.id);
      } else {
        _errorMessage = 'Could not open ${app.name}. Please try again.';
      }
    } on AppApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setPending(app.id, false);
    }
  }

  Future<void> _disconnectCloud(ConnectedAppItem app) async {
    _setPending(app.id, true);
    try {
      await _wearables.disconnect(app.id);
      _replace(app.id, false);
    } on AppApiException catch (e) {
      _errorMessage = e.kind == AppApiErrorKind.network
          ? 'Could not disconnect ${app.name}. Check your connection and try again.'
          : e.message;
    } finally {
      _setPending(app.id, false);
    }
  }

  void _setPending(String id, bool pending) {
    pending ? _pending.add(id) : _pending.remove(id);
    notifyListeners();
  }

  void _replace(String id, bool isConnected) {
    _stored = [
      for (final app in _stored)
        app.id == id ? app.copyWith(isConnected: isConnected) : app,
    ];
  }

  void _onHealthChanged() => notifyListeners();

  void _watch() {
    _subscription = _service.watchConnectedApps().listen((apps) {
      _stored = apps;
      final authorized = _awaitingAuthorization
          .where((id) => apps.any((app) => app.id == id && app.isConnected))
          .toList();
      if (authorized.isNotEmpty) {
        _awaitingAuthorization.removeAll(authorized);
        unawaited(_wearables.closeAuthorization());
      }
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
    _health.removeListener(_onHealthChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
