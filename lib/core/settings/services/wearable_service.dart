import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/services/app_api_client.dart';

class WearableService {
  WearableService({AppApiClient? apiClient})
    : _api = apiClient ?? AppApiClient();

  static const String _providerField = 'provider';
  static const String _urlField = 'url';

  final AppApiClient _api;

  Future<Uri> authorizationUrl(String provider) async {
    final data = await _api.post(
      AppApi.connectWearable,
      body: {_providerField: provider},
    );
    final url = Uri.tryParse(data[_urlField] as String? ?? '');
    if (url == null || !url.hasScheme) {
      throw AppApiException(
        AppApiErrorKind.server,
        AppApiException.fallbackMessage,
      );
    }
    return url;
  }

  Future<bool> openAuthorization(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } catch (e, stackTrace) {
      debugPrint('openAuthorization failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> closeAuthorization() async {
    try {
      if (await supportsCloseForLaunchMode(LaunchMode.inAppBrowserView)) {
        await closeInAppWebView();
      }
    } catch (e, stackTrace) {
      debugPrint('closeAuthorization failed: $e\n$stackTrace');
    }
  }

  Future<void> disconnect(String provider) =>
      _api.post(AppApi.disconnectWearable, body: {_providerField: provider});

  Future<void> sync() async {
    try {
      await _api.post(AppApi.syncWearables);
    } on AppApiException catch (e) {
      debugPrint('wearable sync failed: ${e.message}');
    }
  }
}
