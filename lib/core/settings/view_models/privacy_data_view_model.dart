import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class PrivacyDataViewModel extends ChangeNotifier {
  PrivacyDataViewModel(this._service);

  final SettingsService _service;

  String get title => 'Privacy & Data';

  String get assuranceTitle => 'Your Data is Safe';

  String get assuranceMessage =>
      'All data is encrypted in transit and at rest. We follow GDPR and '
      'Indian Privacy Regulations.';

  String get dangerZoneTitle => 'Danger Zone';

  String get deleteTitle => 'Delete Account';

  String get deleteSubtitle => 'Permanently delete all your data';

  String get deletePromptTitle => 'Delete Account?';

  String get deletePromptMessage =>
      'This will permanently delete all your data, progress, and streak. '
      'This cannot be undone.';

  String get deleteConfirmLabel => 'Yes, I want to Delete';

  List<PrivacyLinkItem> get links => _service.privacyLinks();
}
