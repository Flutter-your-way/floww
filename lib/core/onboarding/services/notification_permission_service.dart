import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floww/core/auth/services/auth_service.dart';

class NotificationPermissionService {
  NotificationPermissionService(this._authService);

  final AuthService _authService;

  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      final uid = _authService.currentUid;
      if (granted && uid != null) await _authService.registerFcmToken(uid);
      return granted;
    } catch (_) {
      return false;
    }
  }
}
