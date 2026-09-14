import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_api.dart';
import 'package:floww/core/nutrition/models/food_model.dart';

enum FoodScanErrorCode {
  invalidRequest,
  unauthorized,
  notFood,
  quotaExceeded,
  aiFailed,
  aiUnavailable,
  network,
  unknown,
}

class FoodScanException implements Exception {
  FoodScanException(this.code, this.message);

  factory FoodScanException.fromJson(Map<String, dynamic> json) =>
      FoodScanException(
        _serverCodes[json['code']] ?? FoodScanErrorCode.unknown,
        json['message'] as String? ?? _fallbackMessage,
      );

  static const String _fallbackMessage =
      'Something went wrong. Please try again.';

  static const Map<String, FoodScanErrorCode> _serverCodes = {
    'INVALID_REQUEST': FoodScanErrorCode.invalidRequest,
    'UNAUTHORIZED': FoodScanErrorCode.unauthorized,
    'NOT_FOOD': FoodScanErrorCode.notFood,
    'QUOTA_EXCEEDED': FoodScanErrorCode.quotaExceeded,
    'AI_FAILED': FoodScanErrorCode.aiFailed,
    'AI_UNAVAILABLE': FoodScanErrorCode.aiUnavailable,
  };

  final FoodScanErrorCode code;
  final String message;

  @override
  String toString() => message;
}

class FoodScanService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FoodModel> scanFood({
    required Uint8List imageBytes,
    required String mimeType,
    String? note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FoodScanException(
        FoodScanErrorCode.unauthorized,
        'Please sign in again.',
      );
    }

    final client = HttpClient()..connectionTimeout = AppApi.connectTimeout;
    try {
      final token = await user.getIdToken();
      final trimmedNote = note?.trim();
      final payload = utf8.encode(
        jsonEncode({
          'image': base64Encode(imageBytes),
          'mimeType': mimeType,
          if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
        }),
      );

      final request = await client.postUrl(AppApi.uri(AppApi.foodScan));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.contentLength = payload.length;
      request.add(payload);

      final response = await request.close().timeout(AppApi.aiResponseTimeout);
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode == HttpStatus.ok) {
        return FoodModel.fromJson(json['data'] as Map<String, dynamic>);
      }
      throw FoodScanException.fromJson(json['error'] as Map<String, dynamic>);
    } on FoodScanException {
      rethrow;
    } on TimeoutException {
      throw FoodScanException(
        FoodScanErrorCode.network,
        'This is taking too long. Check your connection and try again.',
      );
    } on IOException {
      throw FoodScanException(
        FoodScanErrorCode.network,
        'No connection. Check your internet and try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('scanFood failed: $e\n$stackTrace');
      throw FoodScanException(
        FoodScanErrorCode.unknown,
        FoodScanException._fallbackMessage,
      );
    } finally {
      client.close(force: true);
    }
  }
}
