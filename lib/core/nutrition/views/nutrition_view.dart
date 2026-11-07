import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/widgets/guide_target.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/nutrition/models/scanned_food.dart';
import 'package:floww/core/nutrition/models/meal_details_args.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_view_model.dart';
import 'package:floww/core/nutrition/view_models/weekly_report_view_model.dart';
import 'package:floww/core/nutrition/widgets/weekly_summary_card.dart';
import 'package:floww/core/nutrition/views/food_scan_result_sheet.dart';
import 'package:floww/core/nutrition/views/log_food_sheet.dart';
import 'package:floww/core/nutrition/views/macronutrients_sheet.dart';
import 'package:floww/core/nutrition/views/micronutrient_sources_sheet.dart';
import 'package:floww/config/widgets/sheets/app_date_sheet.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/config/widgets/sheets/app_option_sheet.dart';
import 'package:floww/core/nutrition/views/food_log_history_view.dart';
import 'package:floww/core/nutrition/views/water_intake_sheet.dart';
import 'package:floww/core/nutrition/widgets/calorie_summary_card.dart';
import 'package:floww/core/nutrition/widgets/daily_goal_card.dart';
import 'package:floww/core/nutrition/widgets/diet_plan_card.dart';
import 'package:floww/core/nutrition/widgets/flow_impact_card.dart';
import 'package:floww/core/nutrition/widgets/flow_points_card.dart';
import 'package:floww/core/nutrition/widgets/macronutrients_card.dart';
import 'package:floww/core/nutrition/widgets/meal_breakdown_card.dart';
import 'package:floww/core/nutrition/widgets/micronutrient_tiles.dart';
import 'package:floww/core/nutrition/widgets/micronutrients_card.dart';
import 'package:floww/core/nutrition/widgets/nutrition_link_card.dart';
import 'package:floww/core/nutrition/widgets/nutrition_action_buttons.dart';
import 'package:floww/config/widgets/cards/app_empty_state_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/core/nutrition/widgets/start_tracking_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    NutritionViewModel viewModel,
  ) async {
    final picked = await AppDateSheet.show(
      context,
      initialDate: viewModel.selectedDate,
      firstDate: viewModel.firstSelectableDate,
      lastDate: viewModel.lastSelectableDate,
    );
    if (picked != null) viewModel.selectDate(picked);
  }

  Future<void> _scanFood(
    BuildContext context,
    NutritionViewModel viewModel,
  ) async {
    final scanned = await NavigationService.instance.push(AppRouter.foodScan);
    if (scanned is! ScannedFood || !context.mounted) return;
    await FoodScanResultSheet.show(
      context,
      food: scanned.food,
      photo: scanned.photo,
      goal: viewModel.goal,
      date: viewModel.selectedDate,
    );
  }

  void _logFood(
    BuildContext context,
    NutritionViewModel viewModel, [
    MealType? meal,
    String query = '',
  ]) {
    LogFoodSheet.show(
      context,
      date: viewModel.selectedDate,
      meal: meal ?? MealType.forTime(DateTime.now()),
      query: query,
    );
  }

  void _openWater(BuildContext context, NutritionViewModel viewModel) {
    WaterIntakeSheet.show(
      context,
      date: viewModel.selectedDate,
      goal: viewModel.goal,
    );
  }

  Future<void> _editMealsPerDay(
    BuildContext context,
    NutritionViewModel viewModel,
  ) async {
    final picked = await AppOptionSheet.show<int>(
      context,
      title: 'Meals per day',
      icon: Icons.restaurant_rounded,
      options: [
        for (final option in viewModel.mealCountOptions)
          AppSheetOption(
            icon: option.isSelected
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            label: option.label,
            value: option.count,
          ),
      ],
    );
    if (picked != null) await viewModel.setMealsPerDay(picked);
  }

  void _openMeal(NutritionViewModel viewModel, MealType meal) {
    NavigationService.instance.push(
      AppRouter.mealDetails,
      arguments: MealDetailsArgs(date: viewModel.selectedDate, meal: meal),
    );
  }

  Future<void> _openDietPlan(NutritionViewModel viewModel) async {
    await NavigationService.instance.push(AppRouter.dietPlan);
    viewModel.loadDietPlan();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final actionsBottom = bottomInset + AppSizes.s64 + AppSpacing.xl2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<NutritionViewModel>(
        builder: (context, viewModel, child) {
          final revealTrigger = viewModel.selectedDate;

          return Stack(
            fit: StackFit.expand,
            children: [
              AppBackground(
                mode: AppBackgroundMode.active(context),
                safeAreaTop: false,
                scrollable: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sizes.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.paddingOf(context).top + AppSpacing.lg,
                      ),
                      GuideTarget(
                        id: GuideTargetId.nutritionDate,
                        radius: AppRadius.lg,
                        padding: AppSpacing.lg,
                        child: ScreenDateHeader(
                          titlePrefix: viewModel.titlePrefix,
                          title: 'Nutrition',
                          dateLabel: viewModel.dateLabel,
                          direction: viewModel.dateDirection,
                          onPreviousDay: viewModel.canGoPrevious
                              ? viewModel.previousDay
                              : null,
                          onNextDay: viewModel.canGoNext
                              ? viewModel.nextDay
                              : null,
                          onPickDate: () => _pickDate(context, viewModel),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      ChangeNotifierProvider(
                        key: ValueKey(viewModel.weekRangeLabel),
                        create: (_) => WeeklyReportViewModel(
                          NutritionLogService(),
                          viewModel.selectedDate,
                          NutritionGoalService(),
                        ),
                        child: Consumer<WeeklyReportViewModel>(
                          builder: (context, weekly, child) =>
                              WeeklySummaryCard(
                                summary: weekly.summaryLabel,
                                statuses: weekly.compactDayStatuses,
                                onTap: () => NavigationService.instance.push(
                                  AppRouter.weeklyNutritionReport,
                                  arguments: viewModel.selectedDate,
                                ),
                              ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppPopReveal(
                            trigger: revealTrigger,
                            child: viewModel.showFlowImpact
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AppSpacing.xl,
                                    ),
                                    child: FlowImpactCard(
                                      totalPointsLabel:
                                          viewModel.flowPointsTotalLabel,
                                      maxLabel: viewModel.flowImpactMaxLabel,
                                      rows: viewModel.flowPointRows,
                                    ),
                                  )
                                : null,
                          ),
                          LuminosityLayer(
                            enabled: viewModel.showFlowImpact,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showFlowImpact
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: TipCard(
                                            title: viewModel.readOnlyLabel,
                                            icon: Icons
                                                .local_fire_department_rounded,
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showEmptyState
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: AppEmptyStateCard(
                                            title: viewModel.emptyTitle,
                                            message: viewModel.emptyMessage,
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child:
                                      viewModel.showEmptyState &&
                                          viewModel.canLog
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: DailyGoalCard(
                                            calories:
                                                viewModel.calorieGoalLabel,
                                            protein: viewModel.proteinGoalLabel,
                                            carbs: viewModel.carbsGoalLabel,
                                            fats: viewModel.fatsGoalLabel,
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showEmptyState
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: TipCard(
                                            title: viewModel.tipTitle,
                                            message: viewModel.tipMessage,
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child:
                                      viewModel.showDetails &&
                                          viewModel.showStartTracking
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: const StartTrackingCard(),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: GuideTarget(
                                            id: GuideTargetId.nutritionCalories,
                                            child: CalorieSummaryCard(
                                              goalValue:
                                                  viewModel.calorieGoalLabel,
                                              remainingValue: viewModel
                                                  .caloriesRemainingLabel,
                                              consumedValue: viewModel
                                                  .caloriesConsumedLabel,
                                              shareLabel:
                                                  viewModel.calorieShareLabel,
                                              progress:
                                                  viewModel.calorieProgress,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child:
                                      viewModel.showDetails &&
                                          viewModel.showDietPlan
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: DietPlanCard(
                                            nextLabel:
                                                viewModel.dietPlanNextLabel,
                                            daysLabel:
                                                viewModel.dietPlanDaysLabel,
                                            percentLabel:
                                                viewModel.dietPlanPercentLabel,
                                            progress:
                                                viewModel.dietPlanProgress,
                                            onTap: () =>
                                                _openDietPlan(viewModel),
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: GuideTarget(
                                            id: GuideTargetId.nutritionMacros,
                                            child: MacronutrientsCard(
                                              items: viewModel.macros,
                                              onLearnMore: () =>
                                                  MacronutrientsSheet.show(
                                                    context,
                                                    day: viewModel.day,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: GuideTarget(
                                            id: GuideTargetId.nutritionMicros,
                                            child: MicronutrientsCard(
                                              limits: viewModel.limitNutrients,
                                              items: viewModel.micronutrients,
                                              extendedItems: viewModel
                                                  .extendedMicronutrients,
                                              showExtended: viewModel
                                                  .showAllMicronutrients,
                                              toggleLabel: viewModel
                                                  .micronutrientsToggleLabel,
                                              onToggle: viewModel
                                                  .toggleMicronutrients,
                                              note:
                                                  viewModel.micronutrientsNote,
                                              onOpenNutrient: (kind) =>
                                                  MicronutrientSourcesSheet.show(
                                                    context,
                                                    day: viewModel.day,
                                                    kind: kind,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: MicronutrientTile(
                                            item: viewModel.water,
                                            onTap: () =>
                                                _openWater(context, viewModel),
                                            onAdd: viewModel.canLog
                                                ? () => _openWater(
                                                    context,
                                                    viewModel,
                                                  )
                                                : null,
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: GuideTarget(
                                            id: GuideTargetId.nutritionMeals,
                                            child: MealBreakdownCard(
                                              items: viewModel.meals,
                                              mealsPerDayLabel:
                                                  viewModel.mealsPerDayLabel,
                                              onEditMeals: () =>
                                                  _editMealsPerDay(
                                                    context,
                                                    viewModel,
                                                  ),
                                              onOpenMeal: (meal) =>
                                                  _openMeal(viewModel, meal),
                                              onAddToMeal: viewModel.canLog
                                                  ? (meal) => _logFood(
                                                      context,
                                                      viewModel,
                                                      meal,
                                                    )
                                                  : null,
                                              onAddMeal: viewModel.canLog
                                                  ? () => _logFood(
                                                      context,
                                                      viewModel,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AppSpacing.lg,
                                    ),
                                    child: NutritionLinkCard(
                                      title: FoodLogHistoryView.pageTitle,
                                      subtitle:
                                          'Your recent foods · re-log '
                                          'in one tap',
                                      icon: Icons.history_rounded,
                                      onTap: () => NavigationService.instance
                                          .push(AppRouter.foodLogHistory),
                                    ),
                                  ),
                                ),
                                AppPopReveal(
                                  trigger: revealTrigger,
                                  child: viewModel.showDetails
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                          ),
                                          child: FlowPointsCard(
                                            points: viewModel.flowPoints,
                                            maxPoints: viewModel.flowPointsMax,
                                            headline:
                                                viewModel.flowPointsHeadline,
                                            message:
                                                viewModel.flowPointsMessage,
                                            onInfo: () => AppInfoSheet.show(
                                              context,
                                              title: 'Nutrition',
                                              message: viewModel
                                                  .flowPointsInfoMessage,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: actionsBottom + AppSizes.s48 + AppSpacing.xl3,
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.canLog)
                Positioned(
                  right: context.sizes.screenHorizontalPadding,
                  bottom: actionsBottom,
                  child: NutritionActionButtons(
                    onScanFood: () => _scanFood(context, viewModel),
                    onLogFood: () => _logFood(context, viewModel),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
