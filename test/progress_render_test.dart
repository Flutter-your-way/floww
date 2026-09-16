import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/progress_state_entity.dart';
import 'package:floww/config/entities/weight_log_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/views/progress_view.dart';

import 'fakes/fake_nutrition_log_service.dart';
import 'fakes/fake_progress_service.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
}

ProgressRecords _activeRecords() {
  final today = AppDateUtils.dateOnly(DateTime.now());
  final weekStart = AppDateUtils.startOfWeek(today);
  final trackedDays = [
    for (var index = 0; index < DateTime.daysPerWeek; index++)
      AppDateUtils.addDays(weekStart, index),
  ].where((date) => !date.isAfter(today)).toList();

  return ProgressRecords(
    weights: [
      WeightLog(
        id: 'weight-1',
        weightKg: 80.9,
        loggedAt: AppDateUtils.addDays(today, -21),
      ),
      WeightLog(id: 'weight-2', weightKg: 78.8, loggedAt: today),
    ],
    sessions: [
      for (final date in trackedDays)
        WorkoutSessionLog(
          id: 'session-${AppDateUtils.dateKey(date)}',
          workoutId: 'leg-day',
          name: 'Leg Day',
          completedAt: date,
          durationSeconds: 2900,
          exerciseCount: 6,
          totalSets: 18,
          volumeKg: 12450,
        ),
    ],
    habitDays: [
      for (final date in trackedDays)
        HabitDayLog(
          date: date,
          entries: const [
            HabitLogEntry(
              id: 'water_intake',
              title: 'Water Intake',
              value: 3,
              target: 3,
            ),
            HabitLogEntry(
              id: 'meditation',
              title: 'Meditation',
              value: 5,
              target: 10,
            ),
          ],
        ),
    ],
    storedFlow: const [],
    nutrition: NutritionLogs(
      foods: [
        for (final date in trackedDays)
          testFoodLog(
            id: 'meal-${AppDateUtils.dateKey(date)}',
            meal: MealType.lunch,
            at: DateTime(date.year, date.month, date.day, 13),
            calories: 620,
            proteinG: 42,
          ),
      ],
      waters: const [],
    ),
    state: ProgressState.empty,
    goals: const ProgressGoals(startWeightKg: 80.9, targetWeightKg: 70),
  );
}

Future<void> _pumpProgressView(
  WidgetTester tester,
  ProgressViewModel viewModel,
) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.buildTheme(AppThemeMode.flow),
      home: ChangeNotifierProvider.value(
        value: viewModel,
        child: const ProgressView(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await _loadFont(
      'HankenGrotesk',
      'assets/fonts/HankenGrotesk-VariableFont_wght.ttf',
    );
    await _loadFont(
      'PlusJakartaSans',
      'assets/fonts/PlusJakartaSans-VariableFont_wght.ttf',
    );
  });

  testWidgets('progress view renders live data for an active user', (
    tester,
  ) async {
    final service = FakeProgressService(records: _activeRecords());
    final viewModel = ProgressViewModel(service);

    await _pumpProgressView(tester, viewModel);

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('AVERAGE FLOW'), findsOneWidget);
    expect(find.text('Flow Score'), findsOneWidget);
    expect(find.text('WAVE Insights'), findsOneWidget);
    expect(find.text('Weight Tracking'), findsOneWidget);
    expect(find.text('78.80'), findsOneWidget);
    expect(find.text('Workout Volume'), findsOneWidget);
    expect(find.text('Habit Consistency'), findsOneWidget);
    expect(find.text('Personal Records'), findsOneWidget);
    expect(find.text('Getting Started'), findsNothing);
    expect(viewModel.flowScore.hasScores, isTrue);
    expect(viewModel.streakDays, greaterThan(0));
    expect(service.savedFlow, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('progress view renders empty states for a new user', (
    tester,
  ) async {
    final viewModel = ProgressViewModel(FakeProgressService());

    await _pumpProgressView(tester, viewModel);

    expect(find.text('Getting Started'), findsOneWidget);
    expect(find.text('0/5 completed'), findsOneWidget);
    expect(find.text('Welcome to your Progress hub'), findsOneWidget);
    expect(find.text('No scores yet'), findsOneWidget);
    expect(find.text('START A WORKOUT'), findsOneWidget);
    expect(find.text('Start logging your weight'), findsOneWidget);
    expect(find.text('No workouts logged yet'), findsOneWidget);
    expect(find.text('Every expert was once a beginner'), findsOneWidget);
    expect(find.text('WAVE Insights'), findsNothing);
    expect(find.text('Personal Records'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('log weight sheet writes the entry and closes', (tester) async {
    final service = FakeProgressService();
    final viewModel = ProgressViewModel(service);

    await _pumpProgressView(tester, viewModel);

    await tester.tap(find.text('LOG FIRST WEIGHT'));
    await tester.pumpAndSettle();

    expect(find.text('Log Weight'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '76');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Log Weight'), findsNothing);
    expect(viewModel.weight.hasEntries, isTrue);
    expect(viewModel.weightValueLabel, '76.00');
    expect(find.text('76.00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('checklist ticks and dismissals are persisted', (tester) async {
    final service = FakeProgressService();
    final viewModel = ProgressViewModel(service);

    await _pumpProgressView(tester, viewModel);

    await viewModel.toggleChecklistItem('explore_flow');
    await tester.pump();

    expect(viewModel.completedChecklistCount, 1);
    expect(find.text('1/5 completed'), findsOneWidget);
    expect(service.savedStates.last.completedChecklistIds, {'explore_flow'});

    await viewModel.dismissChecklist();
    await tester.pump();

    expect(viewModel.showChecklist, isFalse);
    expect(find.text('Getting Started'), findsNothing);
    expect(service.savedStates.last.isChecklistDismissed, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });
}
