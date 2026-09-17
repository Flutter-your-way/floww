import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/achievements/views/streak_achievements_sheet.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/home/views/flow_mode_sheet.dart';
import 'package:floww/core/home/views/flow_score_breakdown_sheet.dart';
import 'package:floww/core/home/views/recovery_sheet.dart';
import 'package:floww/core/home/widgets/apple_health_sync_card.dart';
import 'package:floww/core/home/widgets/flow_score_boost_card.dart';
import 'package:floww/core/home/widgets/flow_score_card.dart';
import 'package:floww/core/home/widgets/home_header.dart';
import 'package:floww/core/home/widgets/muscle_recovery_card.dart';
import 'package:floww/core/home/widgets/nutrition_summary_card.dart';
import 'package:floww/core/home/widgets/today_habit_card.dart';
import 'package:floww/core/home/widgets/today_progress_card.dart';
import 'package:floww/core/home/widgets/today_workout_card.dart';
import 'package:floww/core/home/widgets/wave_insight_banner.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/view_models/main_tab_controller.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static HomeProvider _createProvider() {
    final nutritionLogService = NutritionLogService();
    final sessionService = WorkoutSessionService();
    final progressService = ProgressService(
      nutritionLogService: nutritionLogService,
    );
    final achievementsService = AchievementsService(
      progressService: progressService,
      sessionService: sessionService,
      nutritionLogService: nutritionLogService,
    );

    return HomeProvider(
      HomeService(
        ProfileService(),
        HabitService(),
        nutritionLogService,
        WorkoutPlanService(WorkoutCatalogService()),
        sessionService,
        HealthLogService(),
        progressService,
      ),
      HomeSnapshotBuilder(),
      achievementsService,
    );
  }

  void _openProfile() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.profile);
  }

  void _startWorkout(BuildContext context, HomeProvider home) {
    HapticManager.light();
    final controller = context.read<MainTabController?>();
    if (home.workout == null && controller != null) {
      controller.select(MainTabController.workoutTab);
      return;
    }
    NavigationService.instance.push(AppRouter.todaysWorkout);
  }

  void _openHabits() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.habitCalendar);
  }

  void _createFirstHabit(BuildContext context) {
    HapticManager.light();
    final controller = context.read<MainTabController?>();
    if (controller == null) {
      NavigationService.instance.push(AppRouter.habitCalendar);
      return;
    }
    controller.openHabitCreation();
  }

  void _openNutrition() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.weeklyNutritionReport);
  }

  void _openBreakdown(BuildContext context, HomeProvider home) {
    HapticManager.light();
    FlowScoreBreakdownSheet.show(context, breakdown: home.flowScoreBreakdown);
  }

  void _openFlowMode(
    BuildContext context,
    HomeProvider home,
    FlowModeDetail detail,
  ) {
    HapticManager.light();
    FlowModeSheet.show(
      context,
      detail: detail,
      onStartWorkout: () {
        NavigationService.instance.pop();
        _startWorkout(context, home);
      },
    );
  }

  void _openRecovery(BuildContext context, HomeProvider home) {
    HapticManager.light();
    RecoverySheet.show(context, detail: home.recoveryDetail);
  }

  void _openStreak(BuildContext context, HomeProvider home) {
    HapticManager.light();
    StreakAchievementsSheet.show(context, summary: home.streakSummary);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (providerContext) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => providerContext.read<HealthProvider>().refresh(),
        );
        return _createProvider();
      },
      child: Scaffold(
        body: AppBackground(
          safeAreaTop: false,
          scrollable: true,
          mode: AppBackgroundMode.flow,
          child: Consumer2<HomeProvider, HealthProvider>(
            builder: (context, home, health, child) {
              final flowMode = home.flowModeDetail;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.paddingOf(context).top + AppSpacing.lg,
                    ),
                    HomeHeader(
                      greeting: home.greeting,
                      userName: home.userName,
                      streakCount: home.streakCount,
                      avatarUrl: context.watch<AuthViewModel>().avatarUrl,
                      onAvatarTap: _openProfile,
                      onStreakTap: () => _openStreak(context, home),
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    FlowScoreCard(
                      percent: home.flowScorePercent,
                      recoveryLevel: home.recoveryLevel,
                      todayMode: home.todayMode,
                      onStartWorkout: () => _startWorkout(context, home),
                      onBreakdownTap: () => _openBreakdown(context, home),
                      onRecoveryTap: home.recoveryDetail.hasData
                          ? () => _openRecovery(context, home)
                          : null,
                      onModeTap: flowMode == null
                          ? null
                          : () => _openFlowMode(context, home, flowMode),
                    ),
                    if (home.flowScorePercent == 0) ...[
                      SizedBox(height: AppSpacing.xl2),
                      FlowScoreBoostCard(boosts: home.flowScoreBoosts),
                    ],
                    SizedBox(height: AppSpacing.xl2),
                    TodayHabitCard(
                      habits: home.habits,
                      onCreateFirstHabit: () => _createFirstHabit(context),
                      onTap: _openHabits,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    TodayWorkoutCard(
                      workout: home.workout,
                      onStartWorkout: () => _startWorkout(context, home),
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    NutritionSummaryCard(
                      nutrition: home.nutrition,
                      onTap: _openNutrition,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    AppleHealthSyncCard(
                      connected: health.isConnected,
                      syncDetail: health.statusLabel,
                      onConnect: health.connect,
                      onDisconnect: health.disconnect,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    TodayProgressCard(progress: home.todayProgress),
                    SizedBox(height: AppSpacing.xl2),
                    MuscleRecoveryCard(
                      data: home.muscleRecovery,
                      frontTemplate: home.muscleMapOf(MuscleBodySide.front),
                      backTemplate: home.muscleMapOf(MuscleBodySide.back),
                      onTap: () => NavigationService.instance.push(
                        AppRouter.muscleRecovery,
                      ),
                    ),
                    if (home.waveInsight != null) ...[
                      SizedBox(height: AppSpacing.xl2),
                      WaveInsightBanner(message: home.waveInsight!),
                    ],
                    SizedBox(
                      height:
                          MediaQuery.viewPaddingOf(context).bottom +
                          AppSizes.s96,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
