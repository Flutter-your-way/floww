import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:floww/config/entities/user_model.dart';
import 'package:floww/config/services/avatar_cache_service.dart';
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

  bool isSigningOut = false;

  bool get isBusy => isGoogleLoading || isAppleLoading || isSigningOut;

  String get logOutTitle => 'Log out?';

  String get logOutMessage =>
      'Your onboarding progress will not be saved. You will need to sign in again to continue.';

  String get logOutLabel => 'Log Out';

  String get cancelLabel => 'Cancel';

  String get createAccountTitle => 'Create your account';

  String get createAccountSubtitle =>
      'Sign in to save your plan and sync your progress across devices.';

  String? get avatarUrl => currentUser?.avatarUrl;

  String? get avatarInitial {
    final name = currentUser?.displayName.trim();
    if (name == null || name.isEmpty) return null;
    return name.characters.first.toUpperCase();
  }

  void _preloadAvatar() {
    final avatarUrl = this.avatarUrl;
    if (avatarUrl == null) return;
    AvatarCacheService.instance.prefetch(avatarUrl);
    unawaited(AvatarCacheService.instance.retainOnly(avatarUrl));
  }

  void _watchAvatar() {
    _avatarSubscription?.cancel();
    if (currentUser == null) return;
    _preloadAvatar();

    _avatarSubscription = _authService.watchAvatarUrl().listen((avatarUrl) {
      final user = currentUser;
      if (user == null || user.avatarUrl == avatarUrl) return;
      currentUser = user.withAvatarUrl(avatarUrl);
      _preloadAvatar();
      if (!_disposed) notifyListeners();
    }, onError: (Object error) => debugPrint('avatar watch failed: $error'));
  }

  @override
  void dispose() {
    _disposed = true;
    _avatarSubscription?.cancel();
    super.dispose();
  }

  Future<bool> hasSeenIntro() => _authService.hasSeenIntro();

  Future<void> markIntroSeen() => _authService.markIntroSeen();

  Future<UserModel?> restoreSession() async {
    try {
      currentUser = await _authService.fetchCurrentUserProfile();
      final uid = currentUser?.uid;
      if (uid != null) unawaited(_authService.syncDeviceClock(uid));
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
      unawaited(_authService.syncDeviceClock(currentUser!.uid));
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

  Future<bool> signOut() async {
    if (isSigningOut) return false;
    errorMessage = null;
    isSigningOut = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await _avatarSubscription?.cancel();
      _avatarSubscription = null;
      currentUser = null;
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSigningOut = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> signInWithApple() async {
    errorMessage = null;
    isAppleLoading = true;
    notifyListeners();

    try {
      currentUser = await _authService.signInWithApple();
      await _authService.registerFcmToken(currentUser!.uid);
      unawaited(_authService.syncDeviceClock(currentUser!.uid));
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
