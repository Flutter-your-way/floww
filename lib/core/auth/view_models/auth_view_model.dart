import 'package:flutter/foundation.dart';
import 'package:floww/config/entities/user_model.dart';
import 'package:floww/core/auth/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;

  bool isGoogleLoading = false;
  bool isAppleLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  bool get isBusy => isGoogleLoading || isAppleLoading;

  String? get avatarUrl => currentUser?.avatarUrl;

  Future<void> requestNotificationPermission() =>
      _authService.requestNotificationPermission();

  Future<UserModel?> restoreSession() async {
    try {
      currentUser = await _authService.fetchCurrentUserProfile();
    } catch (_) {
      currentUser = null;
    }
    notifyListeners();
    return currentUser;
  }

  Future<bool> signInWithGoogle() async {
    errorMessage = null;
    isGoogleLoading = true;
    notifyListeners();

    try {
      currentUser = await _authService.signInWithGoogle();
      await _authService.registerFcmToken(currentUser!.uid);
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isGoogleLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithApple() async {
    errorMessage = null;
    isAppleLoading = true;
    notifyListeners();

    try {
      currentUser = await _authService.signInWithApple();
      await _authService.registerFcmToken(currentUser!.uid);
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isAppleLoading = false;
      notifyListeners();
    }
  }
}
