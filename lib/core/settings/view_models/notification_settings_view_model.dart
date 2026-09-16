import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class NotificationSettingsViewModel extends ChangeNotifier {
  NotificationSettingsViewModel(this._service)
    : _settings = _service.notifications();

  final SettingsService _service;

  NotificationSettings _settings;

  String get title => 'Notifications';

  NotificationToggleItem get master => _settings.master;

  List<NotificationSection> get sections => _settings.sections;

  bool get areTogglesEnabled => _settings.master.isEnabled;

  void setMasterEnabled(bool value) {
    if (_settings.master.isEnabled == value) return;
    _settings = _settings.copyWith(
      master: _settings.master.copyWith(isEnabled: value),
    );
    notifyListeners();
  }

  void setToggleEnabled(String id, bool value) {
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
  }

  void refresh() {
    _settings = _service.notifications();
    notifyListeners();
  }
}
