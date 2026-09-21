import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:floww/config/entities/user_model.dart';
import 'package:floww/core/auth/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;

  bool isGoogleLoading = false;
  bool isAppleLoading = false;
  String? errorMessage;
  UserModel? currentUser;
  StreamSubscription<String?>? _avatarSubscription;
  bool _disposed = false;

  bool get isBusy => isGoogleLoading || isAppleLoading;

  String? get avatarUrl => currentUser?.avatarUrl;

  String? get avatarInitial {
    final name = currentUser?.displayName.trim();
    if (name == null || name.isEmpty) return null;
    return name.characters.first.toUpperCase();
  }

  void _watchAvatar() {
    _avatarSubscription?.cancel();
    if (currentUser == null) return;

    _avatarSubscription = _authService.watchAvatarUrl().listen((avatarUrl) {
      final user = currentUser;
      if (user == null || user.avatarUrl == avatarUrl) return;
      currentUser = user.withAvatarUrl(avatarUrl);
      if (!_disposed) notifyListeners();
    }, onError: (Object error) => debugPrint('avatar watch failed: $error'));
  }

  @override
  void dispose() {
    _disposed = true;
    _avatarSubscription?.cancel();
    super.dispose();
  }

  Future<void> requestNotificationPermission() =>
      _authService.requestNotificationPermission();

  Future<UserModel?> restoreSession() async {
    try {
      currentUser = await _authService.fetchCurrentUserProfile();
    } catch (_) {
      currentUser = null;
    }
    _watchAvatar();
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
      _watchAvatar();
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
      _watchAvatar();
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
