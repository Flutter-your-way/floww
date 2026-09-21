import 'package:flutter/foundation.dart';

import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class PrivacyDataViewModel extends ChangeNotifier {
  PrivacyDataViewModel(this._service, this._authService);

  final SettingsService _service;
  final AuthService _authService;

  bool _isDeleting = false;
  bool _disposed = false;
  String? _errorMessage;

  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;

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

  Future<bool> deleteAccount() async {
    if (_isDeleting) return false;
    _isDeleting = true;
    _errorMessage = null;
    _notify();

    try {
      await _authService.deleteAccount();
      return true;
    } on AuthCancelledException {
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('deleteAccount unexpected failure: $e\n$stackTrace');
      _errorMessage = 'Could not delete your account. Please try again.';
      return false;
    } finally {
      _isDeleting = false;
      _notify();
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
