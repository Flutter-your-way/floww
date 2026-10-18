import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';

class YogaCourseService {
  YogaCourseService({OnboardingAnswersService? answersService})
    : _answersService = answersService ?? OnboardingAnswersService();

  static const String _injuriesKey = 'yoga_injuries';
  static const String _experienceKey = 'yoga_experience';
  static const String _equipmentKey = 'yoga_equipment';
  static const String _safetyKey = 'yoga_safety_acknowledged';

  final OnboardingAnswersService _answersService;

  Future<YogaProfile> loadProfile() async {
    try {
      return profileOf(await _answersService.loadAnswers());
    } catch (error) {
      debugPrint('loadYogaProfile failed: $error');
      return YogaProfile.standard;
    }
  }

  static YogaProfile profileOf(Map<String, dynamic> answers) => YogaProfile(
    cautions: YogaCaution.fromLabels(_listOf(answers[_injuriesKey])),
    ownedProps: _listOf(answers[_equipmentKey]).toSet(),
    startWeek: YogaModuleData.startWeekFor(
      answers[_experienceKey] as String? ?? '',
    ),
  );

  static int weekOf(
    ActiveProgramEntry activeProgram,
    DateTime date,
    YogaProfile profile,
  ) => (activeProgram.weekAt(date) + profile.startWeek - 1).clamp(
    1,
    YogaModuleData.weeks.length,
  );

  Future<bool> hasAcknowledgedSafety() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_safetyKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> acknowledgeSafety() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_safetyKey, true);
    } catch (error) {
      debugPrint('acknowledgeSafety failed: $error');
    }
  }

  static List<String> _listOf(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item is String) item,
  ];
}
