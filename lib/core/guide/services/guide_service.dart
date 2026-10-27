import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/core/guide/models/guide_step.dart';

class GuideService {
  static const String _seenKeyPrefix = 'app_guide_seen';
  static const String _guestId = 'guest';

  String get _seenKey =>
      '${_seenKeyPrefix}_${FirebaseAuth.instance.currentUser?.uid ?? _guestId}';

  Future<Set<GuideSection>> loadSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final names = prefs.getStringList(_seenKey) ?? const [];
      return {
        for (final section in GuideSection.values)
          if (names.contains(section.name)) section,
      };
    } catch (e) {
      debugPrint('GuideService.loadSeen failed: $e');
      return {};
    }
  }

  Future<void> saveSeen(Set<GuideSection> seen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_seenKey, [
        for (final section in seen) section.name,
      ]);
    } catch (e) {
      debugPrint('GuideService.saveSeen failed: $e');
    }
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_seenKey);
    } catch (e) {
      debugPrint('GuideService.reset failed: $e');
    }
  }
}
