import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/services/app_api_client.dart';

class ExerciseVideoService {
  ExerciseVideoService({AppApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient();

  static final Map<String, ExerciseVideo?> _cache = {};

  final AppApiClient _apiClient;

  Future<ExerciseVideo?> find({
    required ExerciseVideoKind kind,
    required List<String> queries,
  }) async {
    final key = '${kind.value}:${queries.join('|').toLowerCase()}';
    if (_cache.containsKey(key)) {
      final cached = _cache[key];
      if (cached == null || !cached.isExpired) return cached;
    }

    try {
      final data = await _apiClient.post(
        AppApi.exerciseVideo,
        body: {'kind': kind.value, 'queries': queries},
        timeout: AppApi.searchResponseTimeout,
      );
      final video = ExerciseVideo.fromJson(data['video']);
      _cache[key] = video;
      return video;
    } catch (e) {
      debugPrint('ExerciseVideoService.find failed: $e');
      return null;
    }
  }
}
