import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/meal_details_args.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/view_models/nutrition_view_model.dart';
import 'package:floww/core/nutrition/views/food_scan_result_sheet.dart';
import 'package:floww/core/nutrition/views/log_food_sheet.dart';
import 'package:floww/core/nutrition/views/macronutrients_sheet.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/nutrition/views/water_intake_sheet.dart';
import 'package:floww/core/nutrition/widgets/calorie_summary_card.dart';
import 'package:floww/core/nutrition/widgets/daily_goal_card.dart';
import 'package:floww/core/nutrition/widgets/diet_plan_card.dart';
import 'package:floww/core/nutrition/widgets/flow_impact_card.dart';
import 'package:floww/core/nutrition/widgets/flow_points_card.dart';
import 'package:floww/core/nutrition/widgets/macronutrients_card.dart';
import 'package:floww/core/nutrition/widgets/meal_breakdown_card.dart';
import 'package:floww/core/nutrition/widgets/micronutrient_tiles.dart';
import 'package:floww/core/nutrition/widgets/nutrition_action_buttons.dart';
import 'package:floww/core/nutrition/widgets/nutrition_empty_state_card.dart';
import 'package:floww/config/widgets/effects/luminosity_layer.dart';
import 'package:floww/config/widgets/headers/screen_date_header.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/core/nutrition/widgets/recent_food_logs_section.dart';
import 'package:floww/core/nutrition/widgets/start_tracking_card.dart';
import 'package:floww/core/nutrition/widgets/weekly_report_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  Future<void> _pickDate(
    BuildContext context,
    NutritionViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
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
    final food = await NavigationService.instance.push(AppRouter.foodScan);
    if (food is! FoodModel || !context.mounted) return;
    await FoodScanResultSheet.show(
      context,
      food: food,
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

  void _openRecentFood(
    BuildContext context,
    NutritionViewModel viewModel,
    RecentFoodItem item,
  ) {
    HapticManager.light();
    _logFood(context, viewModel, item.meal, item.name);
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
                      ScreenDateHeader(
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
                      SizedBox(height: AppSpacing.xl4),
                      DateChangeTransition(
                        value: viewModel.selectedDate,
                        direction: viewModel.dateDirection,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (viewModel.showFlowImpact) ...[
                              FlowImpactCard(
                                totalPointsLabel:
                                    viewModel.flowPointsTotalLabel,
                                maxLabel: viewModel.flowImpactMaxLabel,
                                rows: viewModel.flowPointRows,
                              ),
                              SizedBox(height: AppSpacing.xl),
                            ],
                            LuminosityLayer(
                              enabled: viewModel.showFlowImpact,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (viewModel.showFlowImpact) ...[
                                    TipCard(
                                      title: viewModel.readOnlyLabel,
                                      icon: Icons.local_fire_department_rounded,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                  ],
                                  if (viewModel.showEmptyState) ...[
                                    NutritionEmptyStateCard(
                                      title: viewModel.emptyTitle,
                                      message: viewModel.emptyMessage,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    if (viewModel.canLog) ...[
                                      DailyGoalCard(
                                        calories: viewModel.calorieGoalLabel,
                                        protein: viewModel.proteinGoalLabel,
                                        carbs: viewModel.carbsGoalLabel,
                                        fats: viewModel.fatsGoalLabel,
                                      ),
                                      SizedBox(height: AppSpacing.lg),
                                    ],
                                    TipCard(
                                      title: viewModel.tipTitle,
                                      message: viewModel.tipMessage,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                  ],
                                  if (viewModel.showDetails) ...[
                                    if (viewModel.showStartTracking) ...[
                                      const StartTrackingCard(),
                                      SizedBox(height: AppSpacing.lg),
                                    ],
                                    if (viewModel.showDietPlan) ...[
                                      DietPlanCard(
                                        nextLabel: viewModel.dietPlanNextLabel,
                                        daysLabel: viewModel.dietPlanDaysLabel,
                                        percentLabel:
                                            viewModel.dietPlanPercentLabel,
                                        progress: viewModel.dietPlanProgress,
                                        onTap: () => _openDietPlan(viewModel),
                                      ),
                                      SizedBox(height: AppSpacing.lg),
                                    ],
                                    if (viewModel.showRecentFoods) ...[
                                      RecentFoodLogsSection(
                                        items: viewModel.recentFoods,
                                        onTap: (item) => _openRecentFood(
                                          context,
                                          viewModel,
                                          item,
                                        ),
                                        onViewAll: () =>
                                            _logFood(context, viewModel),
                                      ),
                                      SizedBox(height: AppSpacing.lg),
                                    ],
                                    CalorieSummaryCard(
                                      goalValue: viewModel.calorieGoalLabel,
                                      remainingValue:
                                          viewModel.caloriesRemainingLabel,
                                      consumedValue:
                                          viewModel.caloriesConsumedLabel,
                                      shareLabel: viewModel.calorieShareLabel,
                                      progress: viewModel.calorieProgress,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    MacronutrientsCard(
                                      items: viewModel.macros,
                                      onLearnMore: () =>
                                          MacronutrientsSheet.show(
                                            context,
                                            day: viewModel.day,
                                          ),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    MicronutrientTiles(
                                      items: viewModel.micronutrients,
                                      onOpenWater: () => WaterIntakeSheet.show(
                                        context,
                                        date: viewModel.selectedDate,
                                        goal: viewModel.goal,
                                      ),
                                      onAddWater: viewModel.canLog
                                          ? () => WaterIntakeSheet.show(
                                              context,
                                              date: viewModel.selectedDate,
                                              goal: viewModel.goal,
                                            )
                                          : null,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    MealBreakdownCard(
                                      items: viewModel.meals,
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
                                          ? () => _logFood(context, viewModel)
                                          : null,
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                    FlowPointsCard(
                                      points: viewModel.flowPoints,
                                      maxPoints: viewModel.flowPointsMax,
                                      headline: viewModel.flowPointsHeadline,
                                      message: viewModel.flowPointsMessage,
                                      onInfo: () => AppInfoSheet.show(
                                        context,
                                        title: 'Nutrition',
                                        message:
                                            viewModel.flowPointsInfoMessage,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.lg),
                                  ],
                                  WeeklyReportCard(
                                    rangeLabel: viewModel.weekRangeLabel,
                                    onTap: () =>
                                        NavigationService.instance.push(
                                          AppRouter.weeklyNutritionReport,
                                          arguments: viewModel.selectedDate,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
