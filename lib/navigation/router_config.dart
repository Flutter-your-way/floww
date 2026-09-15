import 'package:floww/core/auth/views/splash_view.dart';
import 'package:floww/core/nutrition/models/meal_details_args.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/food_camera_service.dart';
import 'package:floww/core/nutrition/services/food_scan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/services/photo_library_service.dart';
import 'package:floww/core/nutrition/view_models/diet_plan_view_model.dart';
import 'package:floww/core/nutrition/view_models/food_scan_view_model.dart';
import 'package:floww/core/nutrition/view_models/meal_details_view_model.dart';
import 'package:floww/core/nutrition/view_models/weekly_report_view_model.dart';
import 'package:floww/core/nutrition/views/diet_plan_view.dart';
import 'package:floww/core/nutrition/views/food_scan_view.dart';
import 'package:floww/core/nutrition/views/meal_details_view.dart';
import 'package:floww/core/nutrition/views/weekly_report_view.dart';
import 'package:floww/core/onboarding/views/connect_wearables_view.dart';
import 'package:floww/core/workout/services/workout_service.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/view_models/todays_workout_view_model.dart';
import 'package:floww/core/workout/view_models/workout_details_view_model.dart';
import 'package:floww/core/workout/views/active_workout_view.dart';
import 'package:floww/core/workout/views/todays_workout_view.dart';
import 'package:floww/core/workout/views/workout_details_view.dart';
import 'package:floww/core/onboarding/views/onboarding_question_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/views/auth_view.dart';
import '../core/auth/views/meet_waves_view.dart';
import 'app_router.dart';
import 'views/main_tab_view.dart';

class AppRouterConfig {
  AppRouterConfig._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRouter.meetWaves:
        return MaterialPageRoute(builder: (_) => const MeetWavesView());
      case AppRouter.accountSetup:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case AppRouter.onboardingQuestion:
        return MaterialPageRoute(builder: (_) => OnboardingQuestionView());
      case AppRouter.connectWearables:
        return MaterialPageRoute(builder: (_) => const ConnectWearablesView());
      case AppRouter.home:
        return MaterialPageRoute(builder: (_) => const MainTabView());
      case AppRouter.foodScan:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => FoodScanViewModel(
              FoodCameraService(),
              PhotoLibraryService(),
              FoodScanService(),
            )..startCamera(),
            child: const FoodScanView(),
          ),
        );
      case AppRouter.mealDetails:
        final args = settings.arguments! as MealDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MealDetailsViewModel(
              NutritionLogService(),
              args.date,
              args.meal,
              NutritionGoal.defaults,
            ),
            child: const MealDetailsView(),
          ),
        );
      case AppRouter.weeklyNutritionReport:
        final date = settings.arguments as DateTime? ?? DateTime.now();
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => WeeklyReportViewModel(
              NutritionLogService(),
              date,
              NutritionGoal.defaults,
            ),
            child: const WeeklyReportView(),
          ),
        );
      case AppRouter.dietPlan:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => DietPlanViewModel(
              DietPlanService(NutritionLogService()),
              NutritionGoal.defaults,
            ),
            child: const DietPlanView(),
          ),
        );
      case AppRouter.todaysWorkout:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => TodaysWorkoutViewModel(const WorkoutService()),
            child: const TodaysWorkoutView(),
          ),
        );
      case AppRouter.activeWorkout:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ActiveWorkoutViewModel(const WorkoutService()),
            child: const ActiveWorkoutView(),
          ),
        );
      case AppRouter.workoutDetails:
        final workoutId = settings.arguments! as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                WorkoutDetailsViewModel(const WorkoutService(), workoutId),
            child: const WorkoutDetailsView(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No View Found"))),
        );
    }
  }
}
