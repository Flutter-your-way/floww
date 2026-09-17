import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/flow_category.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/weekly_metric.dart';
import 'package:floww/core/nutrition/view_models/weekly_report_view_model.dart';

import 'fakes/fake_nutrition_goal_service.dart';
import 'fakes/fake_nutrition_log_service.dart';

void main() {
  const goal = NutritionGoal.defaults;

  void logDay(FakeNutritionLogService service, int offset, double ratio) {
    final day = DateTime(2026, 8, 3 + offset);
    for (final meal in [MealType.breakfast, MealType.lunch, MealType.dinner]) {
      service.foodLogs.add(
        testFoodLog(
          id: '$offset-${meal.name}',
          meal: meal,
          at: DateTime(day.year, day.month, day.day, 12),
          calories: goal.calories * ratio / 3,
          proteinG: goal.proteinG * ratio / 3,
          fiberG: 6,
        ),
      );
    }
  }

  Future<WeeklyReportViewModel> buildReport() async {
    final service = FakeNutritionLogService();
    logDay(service, 0, 1);
    logDay(service, 1, 1);
    logDay(service, 2, 1);
    logDay(service, 4, 0.8);
    logDay(service, 5, 0.8);
    logDay(service, 6, 0.8);
    final viewModel = WeeklyReportViewModel(
      service,
      DateTime(2026, 8, 6),
      FakeNutritionGoalService(goal),
    );
    await pumpEventQueue();
    return viewModel;
  }

  test('covers the Monday to Sunday week of the given date', () async {
    final viewModel = await buildReport();

    expect(viewModel.rangeLabel, '3 Aug — 9 Aug');
    expect(viewModel.dailyPointBars.map((bar) => bar.label), [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ]);
    expect(viewModel.maxPoints, FlowCategory.dailyMax * 7);
    viewModel.dispose();
  });

  test('consistency counts logged days and streaks back from Sunday', () async {
    final viewModel = await buildReport();

    expect(viewModel.daysLoggedLabel, '6/7');
    expect(viewModel.calorieStreakLabel, '3 d');
    expect(viewModel.proteinStreakLabel, '3 d');
    expect(
      viewModel.dayStatuses.map((item) => item.status),
      [
        DayLogStatus.full,
        DayLogStatus.full,
        DayLogStatus.full,
        DayLogStatus.none,
        DayLogStatus.full,
        DayLogStatus.full,
        DayLogStatus.full,
      ],
    );
    viewModel.dispose();
  });

  test('flow points breakdown adds up to the weekly total', () async {
    final viewModel = await buildReport();
    final breakdownTotal = viewModel.pointsBreakdown.fold(
      0,
      (total, row) => total + int.parse(row.pointsLabel.substring(1)),
    );

    expect(viewModel.totalPoints, greaterThan(0));
    expect(breakdownTotal, viewModel.totalPoints);
    expect(viewModel.pointsBreakdown.first.detail, 'max 35/wk');
    expect(viewModel.tipMessage, contains('pts/week'));
    viewModel.dispose();
  });

  test('metric totals average over logged days only', () async {
    final viewModel = await buildReport();

    expect(viewModel.metric, WeeklyMetric.calories);
    expect(viewModel.metricTotalLabel, '13,230');
    expect(viewModel.metricAverageLabel, '2,205 avg');
    expect(viewModel.metricWeeklyGoalLabel, '17,150');

    viewModel.selectMetric(WeeklyMetric.fiber);
    expect(viewModel.metricTotalLabel, '108g');
    expect(viewModel.metricAverageLabel, '18g avg');
    expect(viewModel.metricBars[3].valueLabel, isNull);
    viewModel.dispose();
  });
}
