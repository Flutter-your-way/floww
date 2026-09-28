import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_api.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_model.dart';

enum FoodScanErrorCode {
  invalidRequest,
  unauthorized,
  notFood,
  quotaExceeded,
  aiFailed,
  aiUnavailable,
  searchUnavailable,
  serverUnavailable,
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

  static const String _serverUnavailableMessage =
      'Our server is having trouble right now. Please try again in a moment.';

  static const Map<String, FoodScanErrorCode> _serverCodes = {
    'INVALID_REQUEST': FoodScanErrorCode.invalidRequest,
    'UNAUTHORIZED': FoodScanErrorCode.unauthorized,
    'NOT_FOOD': FoodScanErrorCode.notFood,
    'QUOTA_EXCEEDED': FoodScanErrorCode.quotaExceeded,
    'AI_FAILED': FoodScanErrorCode.aiFailed,
    'AI_UNAVAILABLE': FoodScanErrorCode.aiUnavailable,
    'SEARCH_UNAVAILABLE': FoodScanErrorCode.searchUnavailable,
  };

  final FoodScanErrorCode code;
  final String message;

  @override
  String toString() => message;
}

class FoodScanService {
  static const int _logBodyLimit = 200;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<FoodModel> scanFood({
    required Uint8List imageBytes,
    required String mimeType,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    final data = await _post(AppApi.foodScan, AppApi.aiResponseTimeout, {
      'image': base64Encode(imageBytes),
      'mimeType': mimeType,
      if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
    });
    return FoodModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CatalogFood>> searchFoods(String query) async {
    final data = await _post(AppApi.foodSearch, AppApi.searchResponseTimeout, {
      'query': query.trim(),
    });
    return [
      for (final item in data as List<dynamic>)
        CatalogFood.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<FoodModel> describeFood(String text) async {
    final data = await _post(AppApi.foodDescribe, AppApi.aiResponseTimeout, {
      'text': text.trim(),
    });
    return FoodModel.fromJson(data as Map<String, dynamic>);
  }

  Future<Object?> _post(
    String path,
    Duration timeout,
    Map<String, dynamic> body,
  ) async {
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
      final payload = utf8.encode(jsonEncode(body));

      final request = await client.postUrl(AppApi.uri(path));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.contentLength = payload.length;
      request.add(payload);

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      final json = _decodeBody(responseBody);

      if (json == null) {
        debugPrint(
          '$path non-json response: ${response.statusCode} '
          '${responseBody.substring(0, min(responseBody.length, _logBodyLimit))}',
        );
        throw FoodScanException(
          FoodScanErrorCode.serverUnavailable,
          FoodScanException._serverUnavailableMessage,
        );
      }

      if (response.statusCode == HttpStatus.ok) return json['data'];

      final error = json['error'];
      if (error is Map<String, dynamic>) {
        throw FoodScanException.fromJson(error);
      }
      throw FoodScanException(
        FoodScanErrorCode.unknown,
        FoodScanException._fallbackMessage,
      );
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
      debugPrint('$path failed: $e\n$stackTrace');
      throw FoodScanException(
        FoodScanErrorCode.unknown,
        FoodScanException._fallbackMessage,
      );
    } finally {
      client.close(force: true);
    }
  }
}
