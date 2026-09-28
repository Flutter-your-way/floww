import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_api.dart';

enum AppApiErrorKind { unauthorized, rejected, server, network }

class AppApiException implements Exception {
  AppApiException(this.kind, this.message, {this.code});

  static const String fallbackMessage =
      'Something went wrong. Please try again.';
  static const String serverMessage =
      'Our server is having trouble right now. Please try again in a moment.';
  static const String networkMessage =
      'No connection. Check your internet and try again.';

  final AppApiErrorKind kind;
  final String message;
  final String? code;

  bool get isRetryableOffline =>
      kind == AppApiErrorKind.network || kind == AppApiErrorKind.server;

  @override
  String toString() => message;
}

class AppApiClient {
  AppApiClient();

  static const int _logBodyLimit = 200;
  static const int _serverErrorStatus = 500;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
    Duration timeout = AppApi.actionResponseTimeout,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AppApiException(
        AppApiErrorKind.unauthorized,
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
      final json = _decode(responseBody);

      if (response.statusCode == HttpStatus.ok) {
        final data = json?['data'];
        if (data is Map<String, dynamic>) return data;
      }

      final error = json?['error'];
      if (error is Map<String, dynamic>) {
        throw AppApiException(
          _kindOf(response.statusCode),
          error['message'] as String? ?? AppApiException.fallbackMessage,
          code: error['code'] as String?,
        );
      }

      debugPrint(
        '$path unexpected response: ${response.statusCode} '
        '${responseBody.substring(0, responseBody.length.clamp(0, _logBodyLimit))}',
      );
      throw AppApiException(
        AppApiErrorKind.server,
        AppApiException.serverMessage,
      );
    } on AppApiException {
      rethrow;
    } on TimeoutException {
      throw AppApiException(
        AppApiErrorKind.network,
        AppApiException.networkMessage,
      );
    } on IOException {
      throw AppApiException(
        AppApiErrorKind.network,
        AppApiException.networkMessage,
      );
    } catch (e, stackTrace) {
      debugPrint('$path failed: $e\n$stackTrace');
      throw AppApiException(
        AppApiErrorKind.server,
        AppApiException.fallbackMessage,
      );
    } finally {
      client.close(force: true);
    }
  }

  static AppApiErrorKind _kindOf(int status) {
    if (status == HttpStatus.unauthorized) return AppApiErrorKind.unauthorized;
    if (status >= _serverErrorStatus) return AppApiErrorKind.server;
    return AppApiErrorKind.rejected;
  }

  static Map<String, dynamic>? _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
