import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/habits/services/habit_log_service.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/view_models/habits_view_model.dart';
import 'package:floww/core/habits/views/habits_view.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
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

  testWidgets('habits view renders and toggles a habit', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = HabitsViewModel(HabitService(), HabitLogService());

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

    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Habit Score'), findsOneWidget);
    expect(find.text('Weekly Progress'), findsOneWidget);
    expect(find.text('Meditation'), findsOneWidget);

    final completedBefore = viewModel.completedCount;
    viewModel.toggleHabit('meditation');
    await tester.pump();

    expect(viewModel.completedCount, completedBefore + 1);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('add habit sheet suggests, rotates and creates a custom habit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = HabitsViewModel(
      HabitService(seedSampleHabits: false),
      HabitLogService(),
    );

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
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = HabitsViewModel(
      HabitService(seedSampleHabits: false),
      HabitLogService(),
    );

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

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('CREATE FIRST HABIT'), findsOneWidget);
    expect(find.text('Popular Habits to Try'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);

    await tester.tap(find.text('Reading'));
    await tester.pump();

    expect(viewModel.showEmptyState, isFalse);
    expect(find.text('Habit Score'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('a past date renders read-only and cannot be edited', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = HabitsViewModel(HabitService(), HabitLogService());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const HabitsView(),
        ),
      ),
    );

    viewModel.previousDay();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(viewModel.isReadOnly, isTrue);
    expect(viewModel.canEdit, isFalse);
    expect(find.text(viewModel.readOnlyLabel), findsOneWidget);
    expect(find.text('Add a Habit'), findsNothing);

    final completedBefore = viewModel.completedCount;
    viewModel.toggleHabit('meditation');
    await tester.pump();

    expect(viewModel.completedCount, completedBefore);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });
}
