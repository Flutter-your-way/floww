import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/headers/profile_title_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/core/achievements/views/streak_achievements_sheet.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/views/log_weight_sheet.dart';
import 'package:floww/core/progress/views/unlog_weight_sheet.dart';
import 'package:floww/core/progress/widgets/flow_score_summary_card.dart';
import 'package:floww/core/progress/widgets/getting_started_card.dart';
import 'package:floww/core/progress/widgets/habit_consistency_card.dart';
import 'package:floww/core/progress/widgets/personal_records_card.dart';
import 'package:floww/core/progress/widgets/progress_overview_row.dart';
import 'package:floww/core/progress/widgets/wave_insights_card.dart';
import 'package:floww/core/progress/widgets/weight_tracking_card.dart';
import 'package:floww/core/progress/widgets/workout_volume_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  void _openProfile() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.profile);
  }

  void _openStreak(BuildContext context, ProgressViewModel viewModel) {
    HapticManager.light();
    StreakAchievementsSheet.show(context, summary: viewModel.streakSummary);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ProgressViewModel>(
        builder: (context, viewModel, child) {
          final insights = viewModel.insights;
          final errorMessage = viewModel.errorMessage;

          return AppBackground.list(
            mode: AppBackgroundMode.active(context),
            safeAreaTop: false,
            padding: EdgeInsets.symmetric(
              horizontal: context.sizes.screenHorizontalPadding,
            ),
            children: [
              SizedBox(
                height: MediaQuery.paddingOf(context).top + AppSpacing.lg,
              ),
              ProfileTitleHeader(
                eyebrow: viewModel.eyebrow,
                title: viewModel.title,
                streakCount: viewModel.streakDays,
                avatarUrl: auth.avatarUrl,
                avatarInitial: auth.avatarInitial,
                onAvatarTap: _openProfile,
                onStreakTap: () => _openStreak(context, viewModel),
              ),
              SizedBox(height: AppSpacing.xl3),
              if (viewModel.isLoading)
                const AppSectionLoader()
              else if (errorMessage != null)
                AppErrorCard(message: errorMessage, onRetry: viewModel.retry)
              else ...[
                ProgressOverviewRow(stats: viewModel.overviewStats),
                SizedBox(height: AppSpacing.lg),
                if (viewModel.showChecklist) ...[
                  GettingStartedCard(
                    title: 'Getting Started',
                    progressLabel: viewModel.checklistProgressLabel,
                    progress: viewModel.checklistProgress,
                    items: viewModel.checklist,
                    onToggle: (item) => viewModel.toggleChecklistItem(item.id),
                    onDismiss: viewModel.dismissChecklist,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (viewModel.isNewUser) ...[
                  TipCard(
                    title: viewModel.welcomeTitle,
                    message: viewModel.welcomeMessage,
                    icon: Icons.waving_hand_rounded,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                FlowScoreSummaryCard(
                  title: viewModel.flowScoreTitle,
                  rangeLabel: viewModel.weeklyRangeLabel,
                  summary: viewModel.flowScore,
                  scoreLabel: viewModel.flowScoreValueLabel,
                  deltaLabel: viewModel.flowScoreDeltaLabel,
                  isImproving: viewModel.isFlowScoreImproving,
                  emptyTitle: viewModel.flowScoreEmptyTitle,
                  emptyMessage: viewModel.flowScoreEmptyMessage,
                  emptyButtonLabel: viewModel.startWorkoutLabel,
                ),
                SizedBox(height: AppSpacing.lg),
                WeightTrackingCard(
                  viewModel: viewModel,
                  onAddWeight: () => LogWeightSheet.show(
                    context: context,
                    viewModel: viewModel,
                  ),
                  onUnlogWeight: () => UnlogWeightSheet.show(
                    context: context,
                    viewModel: viewModel,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                WorkoutVolumeCard(
                  title: viewModel.volumeTitle,
                  rangeLabel: viewModel.weeklyRangeLabel,
                  volume: viewModel.volume,
                  summaryLabel: viewModel.volumeSummaryLabel,
                  emptyTitle: viewModel.volumeEmptyTitle,
                  emptyMessage: viewModel.volumeEmptyMessage,
                  emptyButtonLabel: viewModel.logWorkoutLabel,
                ),
                SizedBox(height: AppSpacing.lg),
                HabitConsistencyCard(
                  title: viewModel.habitsTitle,
                  items: viewModel.habits,
                  strongestLabel: viewModel.strongestHabitLabel,
                  weakestLabel: viewModel.weakestHabitLabel,
                  strongestHabit: viewModel.strongestHabit,
                  weakestHabit: viewModel.weakestHabit,
                ),
                SizedBox(height: AppSpacing.lg),
                if (insights != null) ...[
                  WaveInsightsCard(
                    title: viewModel.insightsTitle,
                    rangeLabel: viewModel.monthlyRangeLabel,
                    insights: insights,
                    improvementLabel: viewModel.improvementLabel,
                    weaknessLabel: viewModel.weaknessLabel,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
                if (viewModel.showRecords)
                  PersonalRecordsCard(
                    title: viewModel.recordsTitle,
                    records: viewModel.records,
                  )
                else
                  TipCard(
                    title: viewModel.encouragementTitle,
                    message: viewModel.encouragementMessage,
                    icon: Icons.local_fire_department_rounded,
                  ),
              ],
              SizedBox(height: bottomInset + AppSizes.s64 + AppSpacing.xl4),
            ],
          );
        },
      ),
    );
  }
}
