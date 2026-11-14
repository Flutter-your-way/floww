import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/widgets/guide_target.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/animations/tab_content_switcher.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/images/image_precacher.dart';
import 'package:floww/config/widgets/layout/visible_consumer.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/placeholders/app_error_card.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/sheets/app_confirm_sheet.dart';
import 'package:floww/config/widgets/sheets/app_date_sheet.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_card.dart';
import 'package:floww/core/calisthenics/views/cal_principles_sheet.dart';
import 'package:floww/core/calisthenics/widgets/calisthenics_library_section.dart';
import 'package:floww/core/workout/widgets/change_program_card.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/workout_course_view_data.dart';
import 'package:floww/core/workout/models/workout_discipline.dart';
import 'package:floww/core/workout/models/workout_tab.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/views/exercise_detail_sheet.dart';
import 'package:floww/core/workout/widgets/workout_course_card.dart';
import 'package:floww/core/yoga/views/yoga_pose_lesson_sheet.dart';
import 'package:floww/core/yoga/widgets/yoga_library_section.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/view_models/workout_view_model.dart';
import 'package:floww/core/workout/views/log_workout_sheet.dart';
import 'package:floww/core/workout/views/missed_workout_sheet.dart';
import 'package:floww/core/workout/views/muscle_anatomy_sheet.dart';
import 'package:floww/core/workout/views/program_detail_sheet.dart';
import 'package:floww/core/workout/views/program_start_sheet.dart';
import 'package:floww/core/workout/widgets/active_program_card.dart';
import 'package:floww/core/workout/widgets/active_workout_fab.dart';
import 'package:floww/core/workout/widgets/workout_agenda_card.dart';
import 'package:floww/core/workout/widgets/workout_empty_state_card.dart';
import 'package:floww/core/workout/widgets/workout_tab_bar.dart';
import 'package:floww/core/workout/widgets/exercise_library_section.dart';
import 'package:floww/core/workout/models/program_list_args.dart';
import 'package:floww/core/workout/widgets/program_explore_section.dart';
import 'package:floww/core/workout/widgets/program_section_heading.dart';
import 'package:floww/core/workout/widgets/workout_level_report_card.dart';
import 'package:floww/core/workout/widgets/today_workout_hero_card.dart';
import 'package:floww/core/workout/widgets/workout_history_section.dart';
import 'package:floww/core/workout/widgets/workout_overview_section.dart';
import 'package:floww/core/workout/widgets/workout_shift_card.dart';
import 'package:floww/core/wave/views/wave_chat_sheet.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    final picked = await AppDateSheet.show(
      context,
      initialDate: viewModel.selectedDate,
      firstDate: viewModel.firstSelectableDate,
      lastDate: viewModel.lastSelectableDate,
    );
    if (picked != null) viewModel.selectDate(picked);
  }

  void _startWorkout(WorkoutViewModel viewModel) {
    HapticManager.light();
    NavigationService.instance.push(
      AppRouter.todaysWorkout,
      arguments: viewModel.startArgs,
    );
  }

  Future<void> _logWorkout(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    HapticManager.light();
    final sessionId = await LogWorkoutSheet.show(context: context);
    if (sessionId != null) viewModel.focusSession(sessionId);
  }

  void _onAgendaAction(
    WorkoutViewModel viewModel,
    WorkoutAgendaEntryItem entry,
  ) {
    switch (entry.action) {
      case WorkoutAgendaAction.start:
        final args = viewModel.startArgsFor(entry.id);
        if (args == null) return;
        HapticManager.light();
        NavigationService.instance.push(
          AppRouter.todaysWorkout,
          arguments: args,
        );
      case WorkoutAgendaAction.resume:
        final args = viewModel.resumeArgsFor(entry.id);
        if (args == null) return;
        HapticManager.medium();
        NavigationService.instance.push(
          AppRouter.activeWorkout,
          arguments: args,
        );
      case WorkoutAgendaAction.focus:
        final sessionId = viewModel.sessionIdOf(entry.id);
        viewModel.focusEntry(entry.id);
        if (sessionId != null) _openWorkoutDetails(sessionId);
      case null:
        return;
    }
  }

  Future<void> _removeCatchUp(
    BuildContext context,
    WorkoutViewModel viewModel,
    WorkoutAgendaEntryItem entry,
  ) async {
    HapticManager.light();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.removeCatchUpTitle(entry),
      message: viewModel.removeCatchUpMessage(entry),
      confirmLabel: viewModel.removeCatchUpConfirmLabel,
      alternateLabel: viewModel.removeCatchUpCancelLabel,
      icon: Icons.event_busy_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    await viewModel.removeCatchUp(entry.id);
  }

  void _reviewPendingPlan(BuildContext context, WorkoutViewModel viewModel) {
    HapticManager.light();
    showWaveChatSheet(context, day: viewModel.pendingPlanDay);
  }

  Future<void> _buildPlan(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    if (viewModel.needsRebuildWarning) {
      HapticManager.light();
      final choice = await AppConfirmSheet.show(
        context,
        title: viewModel.rebuildWarningTitle,
        message: viewModel.rebuildWarningMessage,
        confirmLabel: viewModel.rebuildWarningConfirm,
        alternateLabel: viewModel.rebuildWarningCancel,
        icon: Icons.warning_amber_rounded,
        isDestructive: true,
      );
      if (choice != AppConfirmChoice.confirm) return;
    }
    HapticManager.medium();
    await viewModel.buildPlan();
  }

  void _resumeWorkout(WorkoutViewModel viewModel) {
    HapticManager.medium();
    NavigationService.instance.push(
      AppRouter.activeWorkout,
      arguments: viewModel.activeWorkoutArgs,
    );
  }

  void _toggleTimer(WorkoutViewModel viewModel) {
    HapticManager.light();
    viewModel.toggleTimer();
  }

  void _showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    HapticManager.light();
    AppInfoSheet.show(context, title: title, message: message);
  }

  void _openAnatomy(BuildContext context, WorkoutViewModel viewModel) {
    final anatomy = viewModel.anatomy;
    if (anatomy == null) return;
    HapticManager.light();
    MuscleAnatomySheet.show(
      context: context,
      anatomy: anatomy,
      templateOf: viewModel.muscleMapOf,
    );
  }

  void _openWorkoutDetails(String workoutId) {
    HapticManager.light();
    NavigationService.instance.push(
      AppRouter.workoutDetails,
      arguments: workoutId,
    );
  }

  void _catchUp(WorkoutViewModel viewModel, MissedWorkoutItem missed) {
    HapticManager.medium();
    viewModel.catchUp(missed);
  }

  void _openMissed(
    BuildContext context,
    WorkoutViewModel viewModel,
    MissedWorkoutItem missed,
  ) {
    HapticManager.light();
    MissedWorkoutSheet.show(
      context: context,
      missed: missed,
      onAction: missed.actionLabel == null
          ? null
          : () {
              Navigator.of(context).maybePop();
              _catchUp(viewModel, missed);
            },
    );
  }

  Future<void> _openProgram(
    BuildContext context,
    WorkoutViewModel viewModel,
    String id,
  ) async {
    final detail = viewModel.programDetailFor(id);
    if (detail == null) return;
    final access = context.read<PremiumAccessProvider>();
    final isLocked =
        detail.isPremium &&
        !detail.isActive &&
        !await access.canUseResolved(PremiumCapability.multiModeWorkouts);
    if (!context.mounted) return;
    HapticManager.light();
    ProgramDetailSheet.show(
      context: context,
      detail: detail,
      isLocked: isLocked,
      onStart: () {
        Navigator.of(context).maybePop();
        if (isLocked) {
          access.openUpgrade();
          return;
        }
        _setUpProgram(context, viewModel, id);
      },
      onCustomize: () {
        Navigator.of(context).maybePop();
        if (isLocked) {
          access.openUpgrade();
          return;
        }
        _openEditor(
          viewModel,
          ProgramEditorArgs(programId: id, editExisting: detail.isCustom),
        );
      },
      onDelete: detail.isCustom
          ? () => _confirmDelete(context, viewModel, detail)
          : null,
      onStop: detail.isActive
          ? () => _confirmStop(context, viewModel, detail)
          : null,
      onCourse: detail.isCourse
          ? () {
              Navigator.of(context).maybePop();
              NavigationService.instance.push(AppRouter.yogaCourse);
            }
          : null,
      onAddToday: (dayIndex) {
        Navigator.of(context).maybePop();
        if (isLocked) {
          access.openUpgrade();
          return;
        }
        _startExtraSession(viewModel, id, dayIndex);
      },
    );
  }

  Future<void> _startExtraSession(
    WorkoutViewModel viewModel,
    String programId,
    int dayIndex,
  ) async {
    HapticManager.medium();
    final args = await viewModel.startExtraSession(programId, dayIndex);
    if (args == null) return;
    NavigationService.instance.push(AppRouter.activeWorkout, arguments: args);
  }

  Future<void> _levelUp(
    BuildContext context,
    WorkoutViewModel viewModel,
  ) async {
    HapticManager.light();
    final programId = viewModel.levelUpProgramId;
    if (programId != null) {
      _openProgram(context, viewModel, programId);
      return;
    }
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.levelUpTitle,
      message: viewModel.levelUpMessage,
      confirmLabel: viewModel.levelUpConfirmLabel,
      alternateLabel: viewModel.levelUpCancelLabel,
      icon: Icons.trending_up_rounded,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    await viewModel.levelUp();
  }

  void _openLevel(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramLevelCardItem level,
  ) {
    final programId = level.programId;
    if (programId == null) {
      _showProgramList(viewModel, () => viewModel.exploreLevel(level.id));
      return;
    }
    _openProgram(context, viewModel, programId);
  }

  void _setUpProgram(
    BuildContext context,
    WorkoutViewModel viewModel,
    String id,
  ) {
    final setup = viewModel.programStartSetupFor(id);
    if (setup == null) return;
    ProgramStartSheet.show(
      context: context,
      setup: setup,
      onStart: (config) => viewModel.startProgram(id, config),
    );
  }

  void _onCourseAction(WorkoutViewModel viewModel, WorkoutCourseAction action) {
    HapticManager.light();
    switch (action) {
      case WorkoutCourseAction.openYogaCourse:
        _openYogaCourse();
      case WorkoutCourseAction.openLibrary:
        viewModel.selectTab(WorkoutTab.exercises);
    }
  }

  void _openYogaCourse() {
    HapticManager.light();
    NavigationService.instance.push(AppRouter.yogaCourse);
  }

  void _openMove(BuildContext context, String moveId) {
    HapticManager.light();
    ExerciseDetailSheet.show(
      context: context,
      viewModel: context.read<ExerciseLibraryViewModel>(),
      exerciseId: moveId,
    );
  }

  void _openPrinciples(BuildContext context, WorkoutViewModel viewModel) {
    HapticManager.light();
    viewModel.markCalPrinciplesRead();
    CalPrinciplesSheet.show(
      context: context,
      title: viewModel.calPrinciplesTitle,
      subtitle: viewModel.calPrinciplesSummary,
      principles: viewModel.calPrinciples,
      safety: viewModel.calSafety,
    );
  }

  void _openProgramSwitcher(WorkoutViewModel viewModel) {
    HapticManager.selection();
    viewModel.openProgramSwitcher();
  }

  Future<void> _openEditor(
    WorkoutViewModel viewModel,
    ProgramEditorArgs args,
  ) async {
    HapticManager.light();
    final result = await NavigationService.instance.push(
      AppRouter.programEditor,
      arguments: args,
    );
    if (result is String) _showProgramList(viewModel, viewModel.showMyPrograms);
  }

  void _showProgramList(WorkoutViewModel viewModel, VoidCallback applyFilter) {
    final isOpen = !viewModel.showProgramExplore;
    applyFilter();
    if (isOpen) return;
    NavigationService.instance.push(
      AppRouter.programList,
      arguments: ProgramListArgs(
        viewModel: viewModel,
        onOpenProgram: (context, id) => _openProgram(context, viewModel, id),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramDetailItem detail,
  ) async {
    Navigator.of(context).maybePop();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.deleteProgramTitle(detail),
      message: viewModel.deleteProgramMessage(detail),
      confirmLabel: 'Delete',
      alternateLabel: 'Cancel',
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    viewModel.deleteProgram(detail.id);
  }

  Future<void> _confirmStop(
    BuildContext context,
    WorkoutViewModel viewModel,
    ProgramDetailItem detail,
  ) async {
    Navigator.of(context).maybePop();
    final choice = await AppConfirmSheet.show(
      context,
      title: viewModel.stopProgramTitle(detail),
      message: viewModel.stopProgramMessage,
      confirmLabel: 'Stop program',
      alternateLabel: 'Keep going',
      icon: Icons.stop_rounded,
      isDestructive: true,
    );
    if (choice != AppConfirmChoice.confirm) return;
    HapticManager.medium();
    viewModel.stopProgram();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final actionsBottom = bottomInset + AppSizes.s64 + AppSpacing.sm;
    final horizontalPadding = EdgeInsets.symmetric(
      horizontal: context.sizes.screenHorizontalPadding,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: VisibleConsumer<WorkoutViewModel>(
        builder: (context, viewModel, child) {
          final suggestion = viewModel.suggestion;
          final overview = viewModel.overview;
          final activeProgram = viewModel.activeProgram;
          final activeProgramId = viewModel.activeProgramId;
          final overviewWorkoutId = viewModel.overviewWorkoutId;
          final shiftOffer = viewModel.shiftOffer;
          final agenda = viewModel.agenda;
          final planBuilder = viewModel.planBuilder;
          final planRebuildLabel = viewModel.planRebuildLabel;
          final levelReport = viewModel.levelReport;
          final pendingPlan = viewModel.pendingPlanBanner;
          final course = viewModel.course;
          final history = viewModel.showHistory ? viewModel.history : null;
          final revealTrigger = viewModel.selectedDate;
          final isProgramsUnlocked = context
              .watch<PremiumAccessProvider>()
              .canUse(PremiumCapability.multiModeWorkouts);

          return ImagePrecacher(
            urls: viewModel.planImageUrls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppBackground(
                  mode: AppBackgroundMode.active(context),
                  safeAreaTop: false,
                  scrollable: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.paddingOf(context).top + AppSpacing.lg,
                      ),
                      Padding(
                        padding: horizontalPadding,
                        child: GuideTarget(
                          id: GuideTargetId.workoutDate,
                          radius: AppRadius.lg,
                          padding: AppSpacing.lg,
                          child: ScreenDateHeader(
                            titlePrefix: viewModel.titlePrefix,
                            title: 'Workouts',
                            dateLabel: viewModel.dateLabel,
                            direction: viewModel.dateDirection,
                            onPreviousDay: viewModel.canGoPrevious
                                ? viewModel.previousDay
                                : null,
                            onNextDay: viewModel.canGoNext
                                ? viewModel.nextDay
                                : null,
                            onPickDate: () => _pickDate(context, viewModel),
                            showDateSelector: viewModel.showDateSelector,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl3),
                      GuideTarget(
                        id: GuideTargetId.workoutTabs,
                        radius: AppRadius.full,
                        child: WorkoutTabBar(
                          tabs: viewModel.tabs,
                          selected: viewModel.selectedTab,
                          onSelected: viewModel.selectTab,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: horizontalPadding,
                        child: TabContentSwitcher(
                          reverse: viewModel.tabReverse,
                          child: Column(
                            key: ValueKey(viewModel.selectedTab),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (viewModel.isLoading ||
                                  viewModel.isHistoryLoading)
                                const AppSectionLoader()
                              else if (viewModel.errorMessage != null)
                                AppErrorCard(
                                  message: viewModel.errorMessage!,
                                  onRetry: viewModel.retry,
                                ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child: pendingPlan == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: WorkoutShiftCard(
                                          icon: Icons.pending_actions_rounded,
                                          title: pendingPlan.title,
                                          message: pendingPlan.message,
                                          actionLabel: pendingPlan.actionLabel,
                                          onAction: () => _reviewPendingPlan(
                                            context,
                                            viewModel,
                                          ),
                                        ),
                                      ),
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child: planBuilder == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: WorkoutShiftCard(
                                          byWave: true,
                                          title: planBuilder.title,
                                          message: planBuilder.message,
                                          actionLabel: planBuilder.actionLabel,
                                          errorMessage:
                                              planBuilder.errorMessage,
                                          isLoading: viewModel.isBuildingPlan,
                                          onAction: () =>
                                              _buildPlan(context, viewModel),
                                          onDismiss:
                                              viewModel.canDismissPlanBanner
                                              ? () {
                                                  HapticManager.selection();
                                                  viewModel.dismissPlanBanner();
                                                }
                                              : null,
                                        ),
                                      ),
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child: shiftOffer == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: GuideTarget(
                                          id: GuideTargetId.workoutShift,
                                          child: PremiumGate(
                                            capability: PremiumCapability
                                                .adaptiveEngine,
                                            placeholder:
                                                const SizedBox.shrink(),
                                            locked: PremiumLockedCard(
                                              capability: PremiumCapability
                                                  .adaptiveEngine,
                                              title: shiftOffer.title,
                                            ),
                                            child: WorkoutShiftCard(
                                              title: shiftOffer.title,
                                              message: shiftOffer.message,
                                              actionLabel:
                                                  shiftOffer.actionLabel,
                                              isLoading: viewModel.isShifting,
                                              onAction: () {
                                                HapticManager.medium();
                                                viewModel.applyShift();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              if (viewModel.isOverviewTab)
                                LuminosityLayer(
                                  enabled: viewModel.isReadOnly,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AppPopReveal(
                                        trigger: revealTrigger,
                                        appearOnMount: true,
                                        child: agenda == null
                                            ? null
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: AppSpacing.lg,
                                                ),
                                                child: GuideTarget(
                                                  id: GuideTargetId
                                                      .workoutAgenda,
                                                  child: WorkoutAgendaCard(
                                                    agenda: agenda,
                                                    onAction: (entry) =>
                                                        _onAgendaAction(
                                                          viewModel,
                                                          entry,
                                                        ),
                                                    onRemove: (entry) =>
                                                        _removeCatchUp(
                                                          context,
                                                          viewModel,
                                                          entry,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      AppPopReveal(
                                        trigger: revealTrigger,
                                        appearOnMount: true,
                                        child: viewModel.showReadOnlyBanner
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: AppSpacing.lg,
                                                ),
                                                child: TipCard(
                                                  title:
                                                      viewModel.readOnlyLabel,
                                                  icon: Icons
                                                      .local_fire_department_rounded,
                                                ),
                                              )
                                            : null,
                                      ),
                                      GuideTarget(
                                        id: GuideTargetId.workoutOverview,
                                        child: WorkoutOverviewSection(
                                          overview: overview,
                                          muscleMapOf: viewModel.muscleMapOf,
                                          revealTrigger: revealTrigger,
                                          showSummary: !viewModel.isReadOnly,
                                          showInsights:
                                              viewModel.showOverviewInsights,
                                          onViewAnatomy: () =>
                                              _openAnatomy(context, viewModel),
                                          onViewDetails:
                                              overviewWorkoutId == null
                                              ? null
                                              : () => _openWorkoutDetails(
                                                  overviewWorkoutId,
                                                ),
                                          onSummaryTap:
                                              viewModel.isOverviewActive
                                              ? () => _resumeWorkout(viewModel)
                                              : null,
                                          onSelectSummary:
                                              viewModel.focusSession,
                                          onOpenSummary: (id) =>
                                              viewModel.isSessionActive(id)
                                              ? _resumeWorkout(viewModel)
                                              : _openWorkoutDetails(id),
                                          onSummaryInfo: () => _showInfo(
                                            context,
                                            title: 'Workout Summary',
                                            message:
                                                viewModel.summaryInfoMessage,
                                          ),
                                          onTrainingEffectInfo: () => _showInfo(
                                            context,
                                            title: 'Training Effect',
                                            message: viewModel
                                                .trainingEffectInfoMessage,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (viewModel.historyResetLabel
                                  case final resetLabel?) ...[
                                TipCard.inline(
                                  title: 'New plan',
                                  message: resetLabel,
                                  icon: Icons.restart_alt_rounded,
                                ),
                                SizedBox(height: AppSpacing.md),
                                PillButton(
                                  variant: PillButtonVariant.outline,
                                  label: viewModel.historyToggleLabel,
                                  onPressed: () {
                                    HapticManager.selection();
                                    viewModel.toggleEarlierHistory();
                                  },
                                ),
                                SizedBox(height: AppSpacing.xl),
                              ],
                              if (viewModel.showHistory && history != null)
                                WorkoutHistorySection(
                                  history: history,
                                  isCatchingUp: viewModel.isShifting,
                                  onOpen: (session) =>
                                      _openWorkoutDetails(session.id),
                                  onOpenMissed: (missed) =>
                                      _openMissed(context, viewModel, missed),
                                  onCatchUp: (missed) =>
                                      _catchUp(viewModel, missed),
                                ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child: viewModel.showEmptyState
                                    ? GuideTarget(
                                        id: GuideTargetId.workoutEmpty,
                                        child: WorkoutEmptyStateCard(
                                          icon: viewModel.emptyState.icon,
                                          iconAsset:
                                              viewModel.emptyState.iconAsset,
                                          title: viewModel.emptyState.title,
                                          message: viewModel.emptyState.message,
                                        ),
                                      )
                                    : null,
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child:
                                    viewModel.showSuggestion &&
                                        suggestion != null
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: AppSpacing.lg,
                                        ),
                                        child: GuideTarget(
                                          id: GuideTargetId.workoutToday,
                                          child: TodayWorkoutHeroCard(
                                            workout: suggestion,
                                            onTap: () =>
                                                _startWorkout(viewModel),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              AppPopReveal(
                                trigger: revealTrigger,
                                appearOnMount: true,
                                child: course == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          top: AppSpacing.lg,
                                        ),
                                        child: WorkoutCourseCard(
                                          course: course,
                                          onAction: () => _onCourseAction(
                                            viewModel,
                                            course.action,
                                          ),
                                        ),
                                      ),
                              ),
                              if (viewModel.showExercises) ...[
                                ChangeProgramCard(
                                  icon: viewModel.discipline.icon,
                                  isWave: viewModel.isCurrentProgramWave,
                                  programName: viewModel.currentProgramName,
                                  actionLabel: viewModel.changeProgramLabel,
                                  onTap: () => _openProgramSwitcher(viewModel),
                                ),
                                SizedBox(height: AppSpacing.xl),
                                switch (viewModel.discipline) {
                                  WorkoutDiscipline.gym =>
                                    const ExerciseLibrarySection(),
                                  WorkoutDiscipline.yoga => YogaLibrarySection(
                                    families: viewModel.yogaLibrary,
                                    suryaSteps: viewModel.yogaSuryaSteps,
                                    suryaIntro: viewModel.yogaSuryaIntro,
                                    onOpenPose: (id) =>
                                        YogaPoseLessonSheet.show(
                                          context: context,
                                          postureId: id,
                                          profile: viewModel.yogaProfile,
                                        ),
                                    onOpenCourse: _openYogaCourse,
                                  ),
                                  WorkoutDiscipline.calisthenics =>
                                    CalisthenicsLibrarySection(
                                      levelLabel: viewModel.calLevelLabel,
                                      ladders: viewModel.calLadders,
                                      warmUp: viewModel.calWarmUp,
                                      coolDown: viewModel.calCoolDown,
                                      principlesTitle:
                                          viewModel.calPrinciplesTitle,
                                      principlesSummary:
                                          viewModel.calPrinciplesSummary,
                                      showPrinciplesBadge:
                                          viewModel.showCalPrinciplesBadge,
                                      onOpenPrinciples: () =>
                                          _openPrinciples(context, viewModel),
                                      onOpenMove: (id) =>
                                          _openMove(context, id),
                                    ),
                                },
                              ],
                              if (viewModel.showPrograms) ...[
                                if ((activeProgram != null &&
                                        activeProgramId != null) ||
                                    planRebuildLabel != null) ...[
                                  const ProgramSectionHeading(
                                    label: 'Your plan',
                                  ),
                                  SizedBox(height: AppSpacing.lg),
                                ],
                                if (activeProgram != null &&
                                    activeProgramId != null) ...[
                                  AppPopReveal(
                                    appearOnMount: true,
                                    child: ActiveProgramCard(
                                      program: activeProgram,
                                      onTap: () => _openProgram(
                                        context,
                                        viewModel,
                                        activeProgramId,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xl3),
                                  if (levelReport != null) ...[
                                    WorkoutLevelReportCard(
                                      report: levelReport,
                                      onLevelUp: () =>
                                          _levelUp(context, viewModel),
                                    ),
                                    SizedBox(height: AppSpacing.xl3),
                                  ],
                                ],
                                if (planRebuildLabel != null) ...[
                                  PillButton(
                                    variant: PillButtonVariant.outline,
                                    height: AppSizes.s44,
                                    label: planRebuildLabel,
                                    icon: Icons.autorenew_rounded,
                                    onPressed: () =>
                                        _buildPlan(context, viewModel),
                                  ),
                                  SizedBox(height: AppSpacing.xl3),
                                ],
                                ProgramExploreSection(
                                  heading: viewModel.catalogHeading,
                                  disciplines: viewModel.catalogDisciplines,
                                  onSelectDiscipline:
                                      viewModel.selectCatalogDiscipline,
                                  goals: viewModel.programGoalCards(
                                    isUnlocked: isProgramsUnlocked,
                                  ),
                                  levels: viewModel.programLevelCards,
                                  collection: viewModel.programCollection,
                                  onSelectGoal: (goalId) => _showProgramList(
                                    viewModel,
                                    () => viewModel.exploreGoal(goalId),
                                  ),
                                  onSelectLevel: (level) =>
                                      _openLevel(context, viewModel, level),
                                  onOpenProgram: (id) =>
                                      _openProgram(context, viewModel, id),
                                  skills: viewModel.skillPrograms,
                                  challenges: viewModel.challengeBoard,
                                  isPremiumUnlocked: isProgramsUnlocked,
                                  onOpenCollection: () {
                                    HapticManager.light();
                                    _showProgramList(
                                      viewModel,
                                      viewModel.showMyPrograms,
                                    );
                                  },
                                  onCreate: viewModel.canCreateProgram
                                      ? () => _openEditor(
                                          viewModel,
                                          const ProgramEditorArgs(),
                                        )
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                      ),
                    ],
                  ),
                ),
                if (viewModel.canLogWorkout ||
                    viewModel.primaryAction == WorkoutPrimaryAction.start)
                  Positioned(
                    left: context.sizes.screenHorizontalPadding,
                    right: context.sizes.screenHorizontalPadding,
                    bottom: actionsBottom,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (viewModel.canLogWorkout &&
                            viewModel.primaryAction ==
                                WorkoutPrimaryAction.start)
                          Expanded(
                            child: PillButton(
                              variant: viewModel.isLogWorkoutPrimary
                                  ? PillButtonVariant.accent
                                  : PillButtonVariant.neutral,
                              label: viewModel.logWorkoutLabel,
                              icon: Icons.add_rounded,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              onPressed: () => _logWorkout(context, viewModel),
                            ),
                          ),
                        if (viewModel.canLogWorkout &&
                            viewModel.primaryAction !=
                                WorkoutPrimaryAction.start)
                          PillButton(
                            variant: viewModel.isLogWorkoutPrimary
                                ? PillButtonVariant.accent
                                : PillButtonVariant.neutral,
                            height: AppSizes.s46,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl2,
                              vertical: AppSpacing.lg,
                            ),
                            icon: Icons.add_rounded,
                            label: viewModel.logWorkoutLabel,
                            labelStyle: AppTypography.labelMediumSemiBold,
                            onPressed: () => _logWorkout(context, viewModel),
                          ),
                        if (viewModel.canLogWorkout &&
                            viewModel.primaryAction ==
                                WorkoutPrimaryAction.start)
                          SizedBox(width: AppSpacing.md),
                        if (viewModel.primaryAction ==
                            WorkoutPrimaryAction.start)
                          Expanded(
                            child: GuideTarget(
                              id: GuideTargetId.workoutStart,
                              radius: AppRadius.full,
                              padding: AppSpacing.xs,
                              child: PillButton(
                                label: viewModel.primaryActionLabel,
                                icon: Icons.play_arrow_rounded,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                ),
                                onPressed: () => _startWorkout(viewModel),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (viewModel.primaryAction == WorkoutPrimaryAction.resume)
                  Positioned(
                    right: context.sizes.screenHorizontalPadding,
                    bottom: actionsBottom,
                    child: ActiveWorkoutFab(
                      statusLabel: viewModel.activeStatusLabel,
                      progressLabel: viewModel.activeProgressLabel,
                      isPaused: viewModel.isTimerPaused,
                      onOpen: () => _resumeWorkout(viewModel),
                      onTogglePause: () => _toggleTimer(viewModel),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
