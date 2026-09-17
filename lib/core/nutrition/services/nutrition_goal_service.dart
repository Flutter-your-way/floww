import 'package:flutter/foundation.dart';

import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_calculator.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/services/profile_service.dart';

class NutritionGoalService {
  NutritionGoalService({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  static const NutritionGoalCalculator _calculator = NutritionGoalCalculator();

  final ProfileService _profileService;

  NutritionGoal goalOf(ProfileAccount account) => _calculator.build(account);

  Stream<NutritionGoal> watch() => _profileService
      .watchAccount()
      .map(goalOf)
      .handleError((Object error) => debugPrint('goal stream failed: $error'));

  Future<NutritionGoal> load() async {
    try {
      return goalOf(await _profileService.loadAccount());
    } catch (e, stackTrace) {
      debugPrint('goal load failed: $e\n$stackTrace');
      return NutritionGoal.defaults;
    }
  }
}
