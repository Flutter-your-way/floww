import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/home/providers/home_provider.dart';
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
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(NutritionLogService()),
      child: Scaffold(
        body: AppBackground(
          safeAreaTop: false,
          scrollable: true,
          mode: AppBackgroundMode.flow,
          child: Consumer2<HomeProvider, HealthProvider>(
            builder: (context, home, health, child) {
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
                      avatarUrl: home.avatarUrl,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    FlowScoreCard(
                      percent: home.flowScorePercent,
                      recoveryLevel: home.recoveryLevel,
                      todayMode: home.todayMode,
                      onStartWorkout: () {},
                    ),
                    if (home.flowScorePercent == 0) ...[
                      SizedBox(height: AppSpacing.xl2),
                      FlowScoreBoostCard(boosts: home.flowScoreBoosts),
                    ],
                    SizedBox(height: AppSpacing.xl2),
                    TodayHabitCard(
                      habits: home.habits,
                      onCreateFirstHabit: () {},
                      onTap: () {},
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    TodayWorkoutCard(
                      workout: home.workout,
                      onStartWorkout: () => NavigationService.instance.push(
                        AppRouter.todaysWorkout,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    NutritionSummaryCard(
                      nutrition: home.nutrition,
                      onTap: () {},
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
                      onTap: () {},
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
