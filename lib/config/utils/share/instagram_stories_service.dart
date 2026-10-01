import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:floww/config/constants/app_social.dart';

class InstagramStoriesService {
  const InstagramStoriesService();

  static const MethodChannel _channel = MethodChannel(
    'floww/instagram_stories',
  );
  static const String _shareMethod = 'shareToStory';

  Future<bool> shareSticker(Uint8List bytes) async {
    try {
      final opened = await _channel.invokeMethod<bool>(_shareMethod, {
        'image': bytes,
        'appId': AppSocial.facebookAppId,
      });
      return opened ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e, stackTrace) {
      debugPrint('shareToStory failed: $e\n$stackTrace');
      return false;
    }
  }
}
