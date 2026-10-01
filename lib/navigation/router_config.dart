import 'dart:typed_data';

import 'package:floww/core/workout/models/active_workout_args.dart';
import 'package:floww/core/workout/models/todays_workout_args.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/view_models/program_editor_view_model.dart';
import 'package:floww/core/workout/views/program_editor_view.dart';

import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/achievements/view_models/achievements_view_model.dart';
import 'package:floww/core/achievements/views/achievements_view.dart';
import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/auth/views/splash_view.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/view_models/habit_calendar_view_model.dart';
import 'package:floww/core/habits/view_models/habit_details_view_model.dart';
import 'package:floww/core/habits/views/habit_calendar_view.dart';
import 'package:floww/core/habits/views/habit_details_view.dart';
import 'package:floww/core/nutrition/models/meal_details_args.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
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
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/widgets/theme/forced_theme_mode.dart';
import 'package:floww/core/onboarding/providers/notification_permission_provider.dart';
import 'package:floww/core/onboarding/services/notification_permission_service.dart';
import 'package:floww/core/onboarding/views/connect_wearables_view.dart';
import 'package:floww/core/onboarding/views/notification_permission_view.dart';
import 'package:floww/core/profile/view_models/edit_daily_targets_view_model.dart';
import 'package:floww/core/profile/view_models/edit_personal_info_view_model.dart';
import 'package:floww/core/profile/views/edit_daily_targets_view.dart';
import 'package:floww/core/profile/views/edit_personal_info_view.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/services/premium_service.dart';
import 'package:floww/core/premium/view_models/premium_upgrade_view_model.dart';
import 'package:floww/core/premium/view_models/premium_view_model.dart';
import 'package:floww/core/premium/views/premium_upgrade_view.dart';
import 'package:floww/core/premium/views/premium_view.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_page.dart';
import 'package:floww/core/profile/models/profile_photo_args.dart';
import 'package:floww/core/profile/services/profile_avatar_service.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/profile/view_models/profile_photo_crop_view_model.dart';
import 'package:floww/core/profile/views/profile_photo_crop_view.dart';
import 'package:floww/core/profile/views/profile_photo_view.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';
import 'package:floww/core/recovery/view_models/muscle_recovery_view_model.dart';
import 'package:floww/core/recovery/views/muscle_recovery_view.dart';
import 'package:floww/core/profile/view_models/profile_view_model.dart';
import 'package:floww/core/profile/views/profile_view.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';
import 'package:floww/core/settings/services/settings_service.dart';
import 'package:floww/core/settings/services/wearable_service.dart';
import 'package:floww/core/settings/view_models/connected_apps_view_model.dart';
import 'package:floww/core/settings/view_models/notification_settings_view_model.dart';
import 'package:floww/core/settings/view_models/onboarding_answer_edit_view_model.dart';
import 'package:floww/core/settings/view_models/onboarding_answers_view_model.dart';
import 'package:floww/core/settings/view_models/privacy_data_view_model.dart';
import 'package:floww/core/settings/view_models/units_view_model.dart';
import 'package:floww/core/settings/views/connected_apps_view.dart';
import 'package:floww/core/settings/views/notification_settings_view.dart';
import 'package:floww/core/settings/views/onboarding_answer_edit_view.dart';
import 'package:floww/core/settings/views/onboarding_answers_view.dart';
import 'package:floww/core/settings/views/privacy_data_view.dart';
import 'package:floww/core/settings/views/units_view.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_alert_service.dart';
import 'package:floww/core/workout/services/workout_readiness_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
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
        return MaterialPageRoute(
          builder: (_) => const ForcedThemeMode(
            mode: AppThemeMode.flow,
            child: SplashView(),
          ),
        );
      case AppRouter.meetWaves:
        return MaterialPageRoute(
          builder: (_) => const ForcedThemeMode(
            mode: AppThemeMode.flow,
            child: MeetWavesView(),
          ),
        );
      case AppRouter.accountSetup:
        return MaterialPageRoute(
          builder: (_) =>
              const ForcedThemeMode(mode: AppThemeMode.flow, child: AuthView()),
        );
      case AppRouter.onboardingQuestion:
        return MaterialPageRoute(
          builder: (_) => ForcedThemeMode(
            mode: AppThemeMode.flow,
            child: OnboardingQuestionView(),
          ),
        );
      case AppRouter.connectWearables:
        return MaterialPageRoute(
          builder: (_) => const ForcedThemeMode(
            mode: AppThemeMode.flow,
            child: ConnectWearablesView(),
          ),
        );
      case AppRouter.notificationPermission:
        return MaterialPageRoute(
          builder: (_) => ForcedThemeMode(
            mode: AppThemeMode.flow,
            child: ChangeNotifierProvider(
              create: (_) => NotificationPermissionProvider(
                NotificationPermissionService(AuthService()),
              ),
              child: const NotificationPermissionView(),
            ),
          ),
        );
      case AppRouter.home:
        return MaterialPageRoute(builder: (_) => const MainTabView());
      case AppRouter.foodScan:
        return MaterialPageRoute(
          builder: (_) => PremiumGate(
            capability: PremiumCapability.aiFoodScan,
            locked: const PremiumLockedPage(
              title: FoodScanView.pageTitle,
              capability: PremiumCapability.aiFoodScan,
            ),
            child: ChangeNotifierProvider(
              create: (_) => FoodScanViewModel(
                FoodCameraService(),
                PhotoLibraryService(),
                FoodScanService(),
              )..startCamera(),
              child: const FoodScanView(),
            ),
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
              NutritionGoalService(),
            ),
            child: const MealDetailsView(),
          ),
        );
      case AppRouter.weeklyNutritionReport:
        final date = settings.arguments as DateTime? ?? DateTime.now();
        return MaterialPageRoute(
          builder: (_) => PremiumGate(
            capability: PremiumCapability.advancedAnalytics,
            locked: const PremiumLockedPage(
              title: WeeklyReportView.pageTitle,
              capability: PremiumCapability.advancedAnalytics,
            ),
            child: ChangeNotifierProvider(
              create: (_) => WeeklyReportViewModel(
                NutritionLogService(),
                date,
                NutritionGoalService(),
              ),
              child: const WeeklyReportView(),
            ),
          ),
        );
      case AppRouter.dietPlan:
        return MaterialPageRoute(
          builder: (_) => PremiumGate(
            capability: PremiumCapability.personalizedRecommendations,
            locked: const PremiumLockedPage(
              title: DietPlanView.pageTitle,
              capability: PremiumCapability.personalizedRecommendations,
            ),
            child: ChangeNotifierProvider(
              create: (_) => DietPlanViewModel(
                DietPlanService(NutritionLogService()),
                NutritionGoalService(),
              ),
              child: const DietPlanView(),
            ),
          ),
        );
      case AppRouter.habitCalendar:
        final date = settings.arguments as DateTime? ?? DateTime.now();
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HabitCalendarViewModel(HabitService(), date),
            child: const HabitCalendarView(),
          ),
        );
      case AppRouter.habitDetails:
        final habitId = settings.arguments! as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HabitDetailsViewModel(HabitService(), habitId),
            child: const HabitDetailsView(),
          ),
        );
      case AppRouter.todaysWorkout:
        final arguments = settings.arguments;
        final todaysArgs = arguments is TodaysWorkoutArgs
            ? arguments
            : TodaysWorkoutArgs(date: arguments as DateTime? ?? DateTime.now());
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => TodaysWorkoutViewModel(
              WorkoutPlanService(WorkoutCatalogService()),
              WorkoutProgramService(),
              WorkoutSessionService(),
              WorkoutReadinessService(),
              context.read<PremiumAccessProvider>(),
              todaysArgs.date,
              catchUpFrom: todaysArgs.catchUpFrom,
            )..load(),
            child: const TodaysWorkoutView(),
          ),
        );
      case AppRouter.activeWorkout:
        final arguments = settings.arguments;
        final launch = arguments is ActiveWorkoutArgs
            ? arguments
            : ActiveWorkoutArgs(date: arguments as DateTime? ?? DateTime.now());
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ActiveWorkoutViewModel(
              WorkoutSessionService(),
              WorkoutPlanService(WorkoutCatalogService()),
              WorkoutProgramService(),
              WorkoutCatalogService(),
              WorkoutReadinessService(),
              WorkoutAlertService(),
              context.read<PremiumAccessProvider>(),
              launch,
            )..load(),
            child: const ActiveWorkoutView(),
          ),
        );
      case AppRouter.programEditor:
        final args =
            settings.arguments as ProgramEditorArgs? ??
            const ProgramEditorArgs();
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProgramEditorViewModel(
              WorkoutCatalogService(),
              WorkoutProgramService(),
              WorkoutPlanService(WorkoutCatalogService()),
              args,
            )..load(),
            child: const ProgramEditorView(),
          ),
        );
      case AppRouter.muscleRecovery:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MuscleRecoveryViewModel(
              MuscleRecoveryService(),
              MuscleMapService(),
            ),
            child: const MuscleRecoveryView(),
          ),
        );
      case AppRouter.achievements:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AchievementsViewModel(AchievementsService()),
            child: const AchievementsView(),
          ),
        );
      case AppRouter.profile:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProfileViewModel(ProfileService(), AuthService()),
            child: const ProfileView(),
          ),
        );
      case AppRouter.editPersonalInfo:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => EditPersonalInfoViewModel(
              ProfileService(),
              ProfileAvatarService(),
            ),
            child: const EditPersonalInfoView(),
          ),
        );
      case AppRouter.profilePhotoCrop:
        final bytes = settings.arguments! as Uint8List;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProfilePhotoCropViewModel(bytes),
            child: ProfilePhotoCropView(),
          ),
        );
      case AppRouter.profilePhoto:
        final args = settings.arguments! as ProfilePhotoArgs;
        return MaterialPageRoute(builder: (_) => ProfilePhotoView(args: args));
      case AppRouter.editDailyTargets:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => EditDailyTargetsViewModel(ProfileService()),
            child: const EditDailyTargetsView(),
          ),
        );
      case AppRouter.connectedApps:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ConnectedAppsViewModel(
              SettingsService(),
              WearableService(),
              context.read<HealthProvider>(),
            ),
            child: const ConnectedAppsView(),
          ),
        );
      case AppRouter.notificationSettings:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => NotificationSettingsViewModel(SettingsService()),
            child: const NotificationSettingsView(),
          ),
        );
      case AppRouter.units:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UnitsViewModel(SettingsService(), ProfileService()),
            child: const UnitsView(),
          ),
        );
      case AppRouter.onboardingAnswers:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                OnboardingAnswersViewModel(OnboardingAnswersService()),
            child: const OnboardingAnswersView(),
          ),
        );
      case AppRouter.editOnboardingAnswer:
        final args = settings.arguments! as OnboardingAnswerEditArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                OnboardingAnswerEditViewModel(OnboardingAnswersService(), args),
            child: const OnboardingAnswerEditView(),
          ),
        );
      case AppRouter.privacyData:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                PrivacyDataViewModel(SettingsService(), AuthService()),
            child: const PrivacyDataView(),
          ),
        );
      case AppRouter.premium:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => PremiumViewModel(PremiumService()),
            child: const PremiumView(),
          ),
        );
      case AppRouter.premiumUpgrade:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => PremiumUpgradeViewModel(PremiumService()),
            child: const PremiumUpgradeView(),
          ),
        );
      case AppRouter.workoutDetails:
        final workoutId = settings.arguments! as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                WorkoutDetailsViewModel(WorkoutSessionService(), workoutId),
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
