import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/constants/app_storage.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/services/profile_service.dart';

class ProfileAvatarService {
  ProfileAvatarService();

  static const double _maxDimension = 720;
  static const int _imageQuality = 88;
  static const Duration _uploadTimeout = Duration(seconds: 45);

  final ImagePicker _picker = ImagePicker();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseStorage get _storage => FirebaseStorage.instance;

  String get _requireUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw ProfileException('Please sign in again.');
    return uid;
  }

  Reference _avatarRef(String uid) => _storage
      .ref(AppStorage.avatars)
      .child(uid)
      .child(AppStorage.avatarFileName);

  Future<Uint8List?> pickImage(ProfileAvatarSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source == ProfileAvatarSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _imageQuality,
      );
      return await picked?.readAsBytes();
    } catch (e, stackTrace) {
      debugPrint('pickAvatar failed: $e\n$stackTrace');
      throw ProfileException(
        source == ProfileAvatarSource.camera
            ? 'Could not open the camera. Allow access in Settings and try again.'
            : 'Could not open your photo library. Please try again.',
      );
    }
  }

  Future<String> upload(Uint8List bytes) async {
    final uid = _requireUserId;
    final now = DateTime.now();

    final task = _avatarRef(uid).putData(
      bytes,
      SettableMetadata(contentType: AppStorage.avatarContentType),
    );

    try {
      await task.timeout(
        _uploadTimeout,
        onTimeout: () {
          task.cancel();
          throw TimeoutException('avatar upload timed out');
        },
      );
      final url = await _avatarRef(uid).getDownloadURL();

      await _firestore.collection(AppCollection.users).doc(uid).set({
        'avatarUrl': url,
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));

      return url;
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('uploadAvatar timed out: $e\n$stackTrace');
      throw ProfileException(
        'Uploading took too long. Check your connection and try again.',
      );
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('uploadAvatar failed [${e.code}]: ${e.message}\n$stackTrace');
      throw ProfileException(_uploadFailureOf(e.code));
    } catch (e, stackTrace) {
      debugPrint('uploadAvatar failed: $e\n$stackTrace');
      throw ProfileException('Could not update your photo. Please try again.');
    }
  }

  static String _uploadFailureOf(String code) => switch (code) {
    'object-not-found' ||
    'bucket-not-found' ||
    'project-not-found' => 'Photo storage is not set up for Floww yet.',
    'unauthorized' => 'You are not allowed to change this photo.',
    'unauthenticated' => 'Please sign in again.',
    'quota-exceeded' => 'Photo storage is full. Please try again later.',
    'retry-limit-exceeded' =>
      'Uploading kept failing. Check your connection and try again.',
    _ => 'Could not update your photo. Please try again.',
  };

  Future<void> remove() async {
    final uid = _requireUserId;
    final now = DateTime.now();

    try {
      await _firestore.collection(AppCollection.users).doc(uid).set({
        'avatarUrl': null,
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('removeAvatar failed: $e\n$stackTrace');
      throw ProfileException('Could not remove your photo. Please try again.');
    }

    try {
      await _avatarRef(uid).delete();
    } catch (e) {
      debugPrint('Skipped missing avatar object: $e');
    }
  }
}
