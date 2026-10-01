import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/constants/app_storage.dart';
import 'package:floww/core/nutrition/models/food_photo_source.dart';
import 'package:floww/core/nutrition/services/food_scan_service.dart';

class FoodImageException implements Exception {
  FoodImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FoodImageService {
  FoodImageService({FoodScanService? api}) : _api = api ?? FoodScanService();

  static const String _lookupsKey = 'food_image_lookups';
  static const String _urlField = 'url';
  static const int _pickQuality = 85;
  static const Duration _uploadTimeout = Duration(seconds: 45);

  final FoodScanService _api;
  final ImagePicker _picker = ImagePicker();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseStorage get _storage => FirebaseStorage.instance;

  String get _requireUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw FoodImageException('Please sign in again.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _images(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.foodImages);

  Reference _imageRef(String uid, String key) => _storage
      .ref(AppStorage.foodImages)
      .child(uid)
      .child('$key${AppStorage.foodImageExtension}');

  Stream<String?> watchUserId() =>
      _auth.authStateChanges().map((user) => user?.uid);

  Stream<Map<String, String>> watchOverrides(String uid) =>
      _images(uid).snapshots().map(
        (snapshot) => {
          for (final doc in snapshot.docs)
            if (doc.data()[_urlField] case final String url) doc.id: url,
        },
      );

  Future<Map<String, String?>> loadLookups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lookupsKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries) entry.key: entry.value as String?,
      };
    } catch (e) {
      debugPrint('load food image lookups failed: $e');
      return {};
    }
  }

  Future<void> saveLookups(Map<String, String?> lookups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lookupsKey, jsonEncode(lookups));
    } catch (e) {
      debugPrint('save food image lookups failed: $e');
    }
  }

  Future<String?> lookup(String name) async {
    try {
      return await _api.lookupFoodImage(name);
    } on FoodScanException catch (e) {
      throw FoodImageException(e.message);
    }
  }

  Future<Uint8List?> pick(FoodPhotoSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source == FoodPhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: AppStorage.foodImageSize.toDouble(),
        maxHeight: AppStorage.foodImageSize.toDouble(),
        imageQuality: _pickQuality,
      );
      return await picked?.readAsBytes();
    } catch (e, stackTrace) {
      debugPrint('pick food photo failed: $e\n$stackTrace');
      throw FoodImageException(
        source == FoodPhotoSource.camera
            ? 'Could not open the camera. Allow access in Settings and try again.'
            : 'Could not open your photo library. Please try again.',
      );
    }
  }

  Future<String> upload({
    required String key,
    required String name,
    required Uint8List bytes,
    required FoodPhotoSource source,
  }) async {
    final uid = _requireUserId;
    final ref = _imageRef(uid, key);

    try {
      final png = await _downscale(bytes);
      final task = ref.putData(
        png,
        SettableMetadata(contentType: AppStorage.foodImageContentType),
      );
      await task.timeout(
        _uploadTimeout,
        onTimeout: () {
          task.cancel();
          throw TimeoutException('food photo upload timed out');
        },
      );
      final url = await ref.getDownloadURL();
      await _images(uid).doc(key).set({
        'name': name.trim(),
        _urlField: url,
        'source': source.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return url;
    } on TimeoutException catch (e) {
      debugPrint('upload food photo timed out: $e');
      throw FoodImageException(
        'Uploading took too long. Check your connection and try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('upload food photo failed: $e\n$stackTrace');
      throw FoodImageException('Could not save that photo. Please try again.');
    }
  }

  Future<void> reset(String key) async {
    final uid = _requireUserId;
    try {
      await _images(uid).doc(key).delete();
    } catch (e, stackTrace) {
      debugPrint('reset food photo failed: $e\n$stackTrace');
      throw FoodImageException('Could not reset that photo.');
    }
    try {
      await _imageRef(uid, key).delete();
    } catch (e) {
      debugPrint('delete food photo file skipped: $e');
    }
  }

  static Future<Uint8List> _downscale(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final longest = descriptor.width > descriptor.height
        ? descriptor.width
        : descriptor.height;
    final scale = longest > AppStorage.foodImageSize
        ? AppStorage.foodImageSize / longest
        : 1.0;
    final codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * scale).round(),
      targetHeight: (descriptor.height * scale).round(),
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    if (data == null) throw FoodImageException('Could not read that photo.');
    return data.buffer.asUint8List();
  }
}
