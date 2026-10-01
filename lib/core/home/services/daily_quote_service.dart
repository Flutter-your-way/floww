import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/services/app_api_client.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';

class DailyQuote {
  const DailyQuote({
    required this.text,
    required this.author,
    required this.date,
  });

  factory DailyQuote.fromJson(Map<String, dynamic> json) => DailyQuote(
    text: json['text'] as String? ?? '',
    author: json['author'] as String? ?? '',
    date: json['date'] as String? ?? '',
  );

  final String text;
  final String author;
  final String date;

  bool get isValid => text.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'text': text,
    'author': author,
    'date': date,
  };
}

class DailyQuoteService {
  DailyQuoteService({AppApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient();

  static const String _cacheKey = 'daily_quote';

  final AppApiClient _apiClient;

  Future<DailyQuote?> today() async {
    final cached = await _readCache();
    if (cached != null && cached.date == AppDateUtils.dateKey(DateTime.now())) {
      return cached;
    }

    try {
      final data = await _apiClient.post(AppApi.dailyQuote);
      final quote = DailyQuote.fromJson(data);
      if (!quote.isValid) return cached;
      await _writeCache(quote);
      return quote;
    } catch (e) {
      debugPrint('DailyQuoteService.today failed: $e');
      return cached;
    }
  }

  Future<DailyQuote?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final quote = DailyQuote.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return quote.isValid ? quote : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(DailyQuote quote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(quote.toJson()));
    } catch (_) {}
  }
}
