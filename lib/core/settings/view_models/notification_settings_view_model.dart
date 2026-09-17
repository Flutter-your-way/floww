import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class NotificationSettingsViewModel extends ChangeNotifier {
  NotificationSettingsViewModel(this._service)
    : _settings = _service.defaultNotifications() {
    _watch();
  }

  final SettingsService _service;

  NotificationSettings _settings;
  StreamSubscription<NotificationSettings>? _subscription;
  bool _disposed = false;

  String get title => 'Notifications';

  NotificationToggleItem get master => _settings.master;

  List<NotificationSection> get sections => _settings.sections;

  bool get areTogglesEnabled => _settings.master.isEnabled;

  Future<void> setMasterEnabled(bool value) async {
    if (_settings.master.isEnabled == value) return;
    _settings = _settings.copyWith(
      master: _settings.master.copyWith(isEnabled: value),
    );
    notifyListeners();
    await _service.setNotificationEnabled(_settings.master.id, value);
  }

  Future<void> setToggleEnabled(String id, bool value) async {
    if (!areTogglesEnabled) return;
    _settings = _settings.copyWith(
      sections: [
        for (final section in _settings.sections)
          section.copyWith(
            items: [
              for (final item in section.items)
                item.id == id ? item.copyWith(isEnabled: value) : item,
            ],
          ),
      ],
    );
    notifyListeners();
    await _service.setNotificationEnabled(id, value);
  }

  void _watch() {
    _subscription = _service.watchNotifications().listen(
      (settings) {
        _settings = settings;
        notifyListeners();
      },
      onError: (Object error) =>
          debugPrint('notification settings failed: $error'),
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
