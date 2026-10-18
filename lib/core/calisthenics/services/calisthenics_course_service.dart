import 'package:flutter/foundation.dart';

import 'package:floww/core/calisthenics/models/cal_gear.dart';
import 'package:floww/core/calisthenics/models/calisthenics_profile.dart';
import 'package:floww/core/calisthenics/services/calisthenics_placement.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';

class CalisthenicsCourseService {
  CalisthenicsCourseService({OnboardingAnswersService? answersService})
    : _answersService = answersService ?? OnboardingAnswersService();

  static const String equipmentKey = 'cal_equipment';
  static const String bodyweightKey = 'cal_bodyweight';

  final OnboardingAnswersService _answersService;

  Future<CalisthenicsProfile> loadProfile() async {
    try {
      return profileOf(await _answersService.loadAnswers());
    } catch (error) {
      debugPrint('loadCalisthenicsProfile failed: $error');
      return CalisthenicsProfile.standard;
    }
  }

  static CalisthenicsProfile profileOf(Map<String, dynamic> answers) {
    final bodyweight = answers[bodyweightKey];
    return CalisthenicsProfile(
      gear: CalGear.fromLabels(_listOf(answers[equipmentKey])),
      results: CalisthenicsPlacement.resultsOf(answers),
      bodyweightKg: bodyweight is num ? bodyweight.toDouble() : null,
    );
  }

  static List<String> _listOf(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item is String) item,
  ];
}
