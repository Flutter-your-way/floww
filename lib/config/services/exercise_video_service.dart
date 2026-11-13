import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/services/app_api_client.dart';

class ExerciseVideoService {
  ExerciseVideoService({AppApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient();

  static const String _storageKey = 'exercise_video_cache_v1';
  static const String _videoField = 'video';
  static const String _fetchedAtField = 'fetchedAt';
  static const Duration _missTtl = Duration(days: 7);

  static final Map<String, _CacheEntry> _cache = {};
  static final Map<String, Future<ExerciseVideo?>> _inFlight = {};
  static Future<void>? _restored;

  final AppApiClient _apiClient;

  Future<ExerciseVideo?> find({
    required ExerciseVideoKind kind,
    required List<String> queries,
  }) async {
    await (_restored ??= _restore());
    final key = '${kind.value}:${queries.join('|').toLowerCase()}';
    final cached = _cache[key];
    if (cached != null && cached.isFresh) return cached.video;
    return _inFlight[key] ??= _fetch(
      key,
      kind,
      queries,
    ).whenComplete(() => _inFlight.remove(key));
  }

  Future<ExerciseVideo?> _fetch(
    String key,
    ExerciseVideoKind kind,
    List<String> queries,
  ) async {
    try {
      final data = await _apiClient.post(
        AppApi.exerciseVideo,
        body: {'kind': kind.value, 'queries': queries},
        timeout: AppApi.searchResponseTimeout,
      );
      final video = ExerciseVideo.fromJson(data['video']);
      if (video == null) {
        debugPrint('ExerciseVideoService.find no match: $queries');
      }
      _cache[key] = _CacheEntry(video: video, fetchedAt: DateTime.now());
      await _persist();
      return video;
    } catch (e) {
      debugPrint('ExerciseVideoService.find failed: $e');
      return null;
    }
  }

  static Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      for (final MapEntry(:key, :value) in decoded.entries) {
        if (value is! Map<String, dynamic>) continue;
        final entry = _CacheEntry(
          video: ExerciseVideo.fromJson(value[_videoField]),
          fetchedAt:
              DateTime.tryParse(value[_fetchedAtField] as String? ?? '') ??
              DateTime.now(),
        );
        if (entry.isFresh) _cache[key] = entry;
      }
    } catch (e) {
      debugPrint('ExerciseVideoService restore failed: $e');
    }
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = {
        for (final MapEntry(:key, :value) in _cache.entries)
          if (value.isFresh)
            key: {
              _videoField: value.video?.toJson(),
              _fetchedAtField: value.fetchedAt.toIso8601String(),
            },
      };
      await prefs.setString(_storageKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('ExerciseVideoService persist failed: $e');
    }
  }
}

class _CacheEntry {
  const _CacheEntry({required this.video, required this.fetchedAt});

  final ExerciseVideo? video;
  final DateTime fetchedAt;

  bool get isFresh {
    final video = this.video;
    if (video != null) return !video.isExpired;
    return DateTime.now().difference(fetchedAt) < ExerciseVideoService._missTtl;
  }
}
