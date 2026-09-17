import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/view_models/habits_view_model.dart';
import 'package:floww/core/habits/views/habits_view.dart';

import 'fakes/fake_habit_service.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
}

HabitDefinition _definition(
  String id,
  String title,
  double target,
  HabitMetric metric, {
  int createdDaysAgo = 30,
}) => HabitDefinition(
  id: id,
  title: title,
  target: target,
  metric: metric,
  icon: HabitIconKind.clipboard,
  createdAt: AppDateUtils.addDays(
    AppDateUtils.dateOnly(DateTime.now()),
    -createdDaysAgo,
  ),
  sortOrder: 0,
);

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

  final habits = [
    _definition(
      'workout_training',
      'Workout Training',
      45,
      HabitMetric.minutes,
    ),
    _definition('outdoor_walk', 'Outdoor Walk', 10000, HabitMetric.steps),
    _definition('water_intake', 'Water Intake', 3, HabitMetric.liters),
    _definition('meditation', 'Meditation', 10, HabitMetric.minutes),
    _definition('screen_free', 'Screen Free', 1, HabitMetric.hours),
  ];

  HabitDayLog todayLog() => HabitDayLog(
    date: AppDateUtils.dateOnly(DateTime.now()),
    entries: const [
      HabitLogEntry(
        id: 'workout_training',
        title: 'Workout Training',
        value: 45,
        target: 45,
        metric: 'minutes',
      ),
      HabitLogEntry(
        id: 'outdoor_walk',
        title: 'Outdoor Walk',
        value: 8432,
        target: 10000,
        metric: 'steps',
      ),
    ],
  );

  Future<HabitsViewModel> pumpHabits(
    WidgetTester tester,
    FakeHabitService service,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(service.dispose);

    final viewModel = HabitsViewModel(service);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const HabitsView(),
        ),
      ),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets('habits view renders logged habits and toggles one', (
    tester,
  ) async {
    final service = FakeHabitService(habits: habits, days: [todayLog()]);
    final viewModel = await pumpHabits(tester, service);

    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Habit Score'), findsOneWidget);
    expect(find.text('Weekly Progress'), findsOneWidget);
    expect(find.text('Meditation'), findsOneWidget);
    expect(find.text('8,432 / 10,000 Steps'), findsOneWidget);
    expect(viewModel.completedCount, 1);

    await viewModel.toggleHabit('meditation');
    await tester.pump();

    expect(viewModel.completedCount, 2);
    expect(service.savedDays.last.entryOf('meditation')?.value, 10);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('add habit sheet suggests, rotates and creates a custom habit', (
    tester,
  ) async {
    final service = FakeHabitService();
    final viewModel = await pumpHabits(tester, service);

    await tester.tap(find.text('CREATE FIRST HABIT'));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose from suggested or create your own'),
      findsOneWidget,
    );
    expect(find.text('WAVE suggests'), findsOneWidget);
    expect(find.text('Improve Recovery'), findsOneWidget);

    await tester.tap(find.text('Try another'));
    await tester.pumpAndSettle();

    expect(find.text('Sharpen Focus'), findsOneWidget);

    await tester.tap(find.text('Create Custom Habit'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Habit'), findsOneWidget);
    expect(find.text('Build something uniquely yours'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Morning Run');
    await tester.enterText(find.byType(TextField).last, '30');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Habit'));
    await tester.pumpAndSettle();

    expect(viewModel.showEmptyState, isFalse);
    expect(viewModel.habits.single.title, 'Morning Run');

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('habits view renders the empty state for a new user', (
    tester,
  ) async {
    final service = FakeHabitService();
    final viewModel = await pumpHabits(tester, service);

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('CREATE FIRST HABIT'), findsOneWidget);
    expect(find.text('Popular Habits to Try'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);

    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();

    expect(viewModel.showEmptyState, isFalse);
    expect(find.text('Habit Score'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('a past date renders read-only and cannot be edited', (
    tester,
  ) async {
    final service = FakeHabitService(habits: habits, days: [todayLog()]);
    final viewModel = await pumpHabits(tester, service);

    viewModel.previousDay();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(viewModel.isReadOnly, isTrue);
    expect(viewModel.canEdit, isFalse);
    expect(find.text(viewModel.readOnlyLabel), findsOneWidget);
    expect(find.text('Add a Habit'), findsNothing);

    final completedBefore = viewModel.completedCount;
    await viewModel.toggleHabit('meditation');
    await tester.pump();

    expect(viewModel.completedCount, completedBefore);
    expect(service.savedDays, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });
}
