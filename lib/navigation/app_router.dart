import 'package:floww/config/entities/user_model.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String meetWaves = '/meet_waves';
  static const String accountSetup = '/account_setup';
  static const String onboardingQuestion = '/onboardingQuestion';
  static const String connectWearables = '/connect_wearables';
  static const String home = '/home';
  static const String foodScan = '/food_scan';
  static const String mealDetails = '/meal_details';
  static const String weeklyNutritionReport = '/weekly_nutrition_report';
  static const String dietPlan = '/diet_plan';
  static const String workoutDetails = '/workout_details';
  static const String todaysWorkout = '/todays_workout';
  static const String activeWorkout = '/active_workout';

  static String routeAfterAuth(UserModel user) {
    if (user.onboardingCompleted) return home;
    if (user.answersSubmitted) return connectWearables;
    return onboardingQuestion;
  }
}
