import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_reply.dart';
import 'package:floww/core/wave/models/wave_today_payload.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';

enum WaveChatErrorCode {
  invalidRequest,
  unauthorized,
  quotaExceeded,
  aiFailed,
  aiUnavailable,
  serverUnavailable,
  network,
  unknown,
}

class WaveChatException implements Exception {
  WaveChatException(this.code, this.message);

  factory WaveChatException.fromJson(Map<String, dynamic> json) =>
      WaveChatException(
        _serverCodes[json['code']] ?? WaveChatErrorCode.unknown,
        json['message'] as String? ?? _fallbackMessage,
      );

  static const String _fallbackMessage =
      'I could not reach my brain just then. Try me again.';

  static const String _serverUnavailableMessage =
      'My connection is having trouble right now. Try again in a moment.';

  static const Map<String, WaveChatErrorCode> _serverCodes = {
    'INVALID_REQUEST': WaveChatErrorCode.invalidRequest,
    'UNAUTHORIZED': WaveChatErrorCode.unauthorized,
    'QUOTA_EXCEEDED': WaveChatErrorCode.quotaExceeded,
    'AI_FAILED': WaveChatErrorCode.aiFailed,
    'AI_UNAVAILABLE': WaveChatErrorCode.aiUnavailable,
  };

  final WaveChatErrorCode code;
  final String message;

  @override
  String toString() => message;
}

class WaveAiService {
  static const int historyTurns = 8;
  static const int maxHistoryLength = 360;
  static const int maxMessageLength = 1000;
  static const int _logBodyLimit = 200;

  static const Set<WaveMessageKind> _historyKinds = {
    WaveMessageKind.user,
    WaveMessageKind.reply,
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<WaveReply> ask({
    required String message,
    required WaveContext context,
    required List<WaveTranscriptEntry> history,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw WaveChatException(
        WaveChatErrorCode.unauthorized,
        'Please sign in again.',
      );
    }

    final client = HttpClient()..connectionTimeout = AppApi.connectTimeout;
    try {
      final token = await user.getIdToken();
      final payload = utf8.encode(
        jsonEncode({
          'message': _clamp(message, maxMessageLength),
          'history': historyOf(history),
          if (context.isReady)
            'today': WaveTodayPayload.fromContext(context).toJson(),
        }),
      );

      final request = await client.postUrl(AppApi.uri(AppApi.waveChat));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.contentLength = payload.length;
      request.add(payload);

      final response = await request.close().timeout(AppApi.aiResponseTimeout);
      final body = await response.transform(utf8.decoder).join();
      final json = _decodeBody(body);

      if (json == null) {
        debugPrint(
          'waveChat non-json response: ${response.statusCode} '
          '${body.substring(0, min(body.length, _logBodyLimit))}',
        );
        throw WaveChatException(
          WaveChatErrorCode.serverUnavailable,
          WaveChatException._serverUnavailableMessage,
        );
      }

      if (response.statusCode == HttpStatus.ok) {
        return WaveReply.fromJson(json['data'] as Map<String, dynamic>);
      }

      final error = json['error'];
      if (error is Map<String, dynamic>) {
        throw WaveChatException.fromJson(error);
      }
      throw WaveChatException(
        WaveChatErrorCode.unknown,
        WaveChatException._fallbackMessage,
      );
    } on WaveChatException {
      rethrow;
    } on TimeoutException {
      throw WaveChatException(
        WaveChatErrorCode.network,
        'That took too long. Check your connection and ask me again.',
      );
    } on IOException {
      throw WaveChatException(
        WaveChatErrorCode.network,
        'No connection. Check your internet and ask me again.',
      );
    } catch (e, stackTrace) {
      debugPrint('waveChat failed: $e\n$stackTrace');
      throw WaveChatException(
        WaveChatErrorCode.unknown,
        WaveChatException._fallbackMessage,
      );
    } finally {
      client.close(force: true);
    }
  }

  List<Map<String, String>> historyOf(List<WaveTranscriptEntry> entries) {
    final turns = <Map<String, String>>[];

    for (final entry in entries.reversed) {
      if (turns.length >= historyTurns) break;
      if (!_historyKinds.contains(entry.kind)) continue;
      final text = _clamp(entry.text ?? '', maxHistoryLength);
      if (text.isEmpty) continue;
      turns.add({
        'role': entry.kind == WaveMessageKind.user ? 'user' : 'wave',
        'text': text,
      });
    }

    return turns.reversed.toList();
  }

  static String _clamp(String value, int max) {
    final trimmed = value.trim();
    return trimmed.length <= max ? trimmed : trimmed.substring(0, max);
  }

  Map<String, dynamic>? _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
