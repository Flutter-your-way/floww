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
  static const String habitCalendar = '/habit_calendar';
  static const String habitDetails = '/habit_details';
  static const String workoutDetails = '/workout_details';
  static const String todaysWorkout = '/todays_workout';
  static const String activeWorkout = '/active_workout';
  static const String muscleRecovery = '/muscle_recovery';
  static const String achievements = '/achievements';
  static const String profile = '/profile';
  static const String editPersonalInfo = '/edit_personal_info';
  static const String editDailyTargets = '/edit_daily_targets';
  static const String profilePhotoCrop = '/profile_photo_crop';
  static const String profilePhoto = '/profile_photo';
  static const String premium = '/premium';
  static const String premiumUpgrade = '/premium_upgrade';
  static const String connectedApps = '/connected_apps';
  static const String notificationSettings = '/notification_settings';
  static const String units = '/units';
  static const String privacyData = '/privacy_data';

  static String routeAfterAuth(UserModel user) {
    if (user.onboardingCompleted) return home;
    if (user.answersSubmitted) return connectWearables;
    return onboardingQuestion;
  }
}
