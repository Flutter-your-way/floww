import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  bool _googleSignInInitialized = false;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppCollection.users);

  Future<UserModel> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Could not sign in with Google. Please try again.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return await _findOrCreateUser(
        userCredential.user!,
        provider: AuthProvider.google,
        displayName: googleUser.displayName ?? '',
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
      if (!await SignInWithApple.isAvailable()) {
        throw AuthException(
          'Sign in with Apple is not available on this device.',
        );
      }

      final rawNonce = generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null) {
        throw AuthException('Could not sign in with Apple. Please try again.');
      }

      final oauthCredential = AppleAuthProvider.credentialWithIDToken(
        identityToken,
        rawNonce,
        AppleFullPersonName(
          givenName: appleCredential.givenName,
          familyName: appleCredential.familyName,
        ),
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user!;
      final name =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();

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

    final data = doc.data()!;
    final storedAvatarUrl = data['avatarUrl'] as String?;
    if (storedAvatarUrl == null && firebaseUser.photoURL != null) {
      return UserModel.fromJson({...data, 'avatarUrl': firebaseUser.photoURL});
    }

    return UserModel.fromJson(data);
  }

  Future<void> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      final token = await FirebaseMessaging.instance.getToken();
      if (uid != null && token != null) {
        await _usersCollection.doc(uid).update({
          'fcmToken': FieldValue.arrayRemove([token]),
        });
      }
    } catch (_) {
      debugPrint('signOut token cleanup skipped');
    }

    try {
      if (_googleSignInInitialized) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
      throw AuthException('Could not sign you out. Please try again.');
    }
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
      if (doc.data()?['avatarUrl'] == null && firebaseUser.photoURL != null)
        'avatarUrl': firebaseUser.photoURL,
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
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
