import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/user_model.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthCancelledException extends AuthException {
  AuthCancelledException(super.message);
}

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  static Future<void>? _googleSignInSetup;

  static bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignIn() {
    return _googleSignInSetup ??= _googleSignIn.initialize().then((_) {
      _googleSignInInitialized = true;
    });
  }

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppCollection.users);

  Future<UserModel> signInWithGoogle() async {
    try {
      final google = await _googleCredential();
      final userCredential = await _auth.signInWithCredential(
        google.credential,
      );
      return await _findOrCreateUser(
        userCredential.user!,
        provider: AuthProvider.google,
        displayName: google.displayName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Sign in was cancelled.');
      }
      throw AuthException('Could not sign in with Google. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Could not sign in with Google. Please try again.');
    }
  }

  Future<UserModel> signInWithApple() async {
    try {
      final apple = await _appleCredential();
      final userCredential = await _auth.signInWithCredential(apple.credential);
      final firebaseUser = userCredential.user!;
      final name = apple.displayName;

      if (name.isNotEmpty && (firebaseUser.displayName ?? '').isEmpty) {
        await firebaseUser.updateDisplayName(name);
        await firebaseUser.reload();
      }

      return await _findOrCreateUser(
        _auth.currentUser ?? firebaseUser,
        provider: AuthProvider.apple,
        displayName: name,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException('Sign in was cancelled.');
      }
      throw AuthException('Could not sign in with Apple. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Could not sign in with Apple. Please try again.');
    }
  }

  DateTime? get accountCreatedAt {
    try {
      return _auth.currentUser?.metadata.creationTime;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> fetchCurrentUserProfile() async {
    final firebaseUser = await _auth.authStateChanges().first;
    if (firebaseUser == null) return null;

    final doc = await _usersCollection.doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  Stream<String?> watchAvatarUrl() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream<String?>.empty();

    return _usersCollection
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['avatarUrl'] as String?);
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _removeFcmToken(uid);

    try {
      if (_googleSignInInitialized) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
      throw AuthException('Could not sign you out. Please try again.');
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Please sign in again.');

    await _removeFcmToken(user.uid);
    await _requestAccountDeletion(user);

    try {
      if (_googleSignInInitialized) await _googleSignIn.signOut();
    } catch (_) {
      debugPrint('deleteAccount google sign out skipped');
    }

    try {
      await _auth.signOut();
    } catch (e, stackTrace) {
      debugPrint('deleteAccount local sign out skipped: $e\n$stackTrace');
    }
  }

  Future<void> _requestAccountDeletion(User user) async {
    final client = HttpClient()..connectionTimeout = AppApi.connectTimeout;
    try {
      final token = await user.getIdToken();
      final request = await client.deleteUrl(AppApi.uri(AppApi.account));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      final response = await request.close().timeout(
        AppApi.accountDeleteTimeout,
      );
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == HttpStatus.ok) return;

      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      debugPrint('deleteAccount rejected: ${response.statusCode} $body');
      throw AuthException(
        error?['message'] as String? ??
            'Could not delete your account. Please try again.',
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException(
        'This is taking too long. Check your connection and try again.',
      );
    } on IOException {
      throw AuthException(
        'No connection. Check your internet and try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('deleteAccount request failed: $e\n$stackTrace');
      throw AuthException('Could not delete your account. Please try again.');
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _removeFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _usersCollection.doc(uid).update({
        'fcmToken': FieldValue.arrayRemove([token]),
      });
    } catch (_) {
      debugPrint('deleteAccount token cleanup skipped');
    }
  }

  Future<({AuthCredential credential, String displayName})>
  _googleCredential() async {
    await _ensureGoogleSignIn();
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthCancelledException('Sign in was cancelled.');
      }
      rethrow;
    }
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('Could not sign in with Google. Please try again.');
    }
    return (
      credential: GoogleAuthProvider.credential(idToken: idToken),
      displayName: googleUser.displayName ?? '',
    );
  }

  Future<({AuthCredential credential, String displayName})>
  _appleCredential() async {
    if (!await SignInWithApple.isAvailable()) {
      throw AuthException(
        'Sign in with Apple is not available on this device.',
      );
    }

    final rawNonce = generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthCancelledException('Sign in was cancelled.');
      }
      rethrow;
    }

    final identityToken = appleCredential.identityToken;
    if (identityToken == null) {
      throw AuthException('Could not sign in with Apple. Please try again.');
    }

    return (
      credential: AppleAuthProvider.credentialWithIDToken(
        identityToken,
        rawNonce,
        AppleFullPersonName(
          givenName: appleCredential.givenName,
          familyName: appleCredential.familyName,
        ),
      ),
      displayName:
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim(),
    );
  }

  Future<void> registerFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _usersCollection.doc(uid).update({
        'fcmToken': FieldValue.arrayUnion([token]),
      });
    } catch (_) {
      return;
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {
      return;
    }
  }

  Future<UserModel> _findOrCreateUser(
    User firebaseUser, {
    required AuthProvider provider,
    required String displayName,
  }) async {
    final docRef = _usersCollection.doc(firebaseUser.uid);
    final doc = await docRef.get();
    final now = DateTime.now();

    if (!doc.exists) {
      final user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: displayName.isNotEmpty
            ? displayName
            : (firebaseUser.displayName ?? ''),
        avatarUrl: firebaseUser.photoURL,
        provider: provider,
        mode: AppThemeMode.flow,
        onboardingCompleted: false,
        answersSubmitted: false,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );
      await docRef.set(user.toJson());
      return user;
    }

    final resolvedName = displayName.isNotEmpty
        ? displayName
        : (firebaseUser.displayName ?? '');
    final storedName = doc.data()?['displayName'] as String?;
    final updatedFields = {
      'lastLoginAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      if ((storedName == null || storedName.isEmpty) && resolvedName.isNotEmpty)
        'displayName': resolvedName,
    };
    await docRef.update(updatedFields);
    return UserModel.fromJson({...doc.data()!, ...updatedFields});
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'requires-recent-login':
        return 'Please sign in again before deleting your account.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
