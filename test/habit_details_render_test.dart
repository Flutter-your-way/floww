import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/view_models/habit_details_view_model.dart';
import 'package:floww/core/habits/views/habit_details_view.dart';

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

  Future<HabitDetailsViewModel> pumpDetails(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = HabitDetailsViewModel(
      HabitService(),
      'workout_training',
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const HabitDetailsView(),
        ),
      ),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets('habit details renders the habit, stats and progress', (
    tester,
  ) async {
    final viewModel = await pumpDetails(tester);

    expect(find.text('Habit Details'), findsOneWidget);
    expect(find.text('Workout Training'), findsOneWidget);
    expect(find.text('At least 45 min workout'), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('Longest Streak'), findsOneWidget);
    expect(find.text('Weekly Average'), findsOneWidget);
    expect(find.text('Total Completions'), findsOneWidget);
    expect(find.text('Habit Progress'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('About This Habit'), findsOneWidget);

    expect(viewModel.stats.length, 4);
  });

  testWidgets('habit details switches the progress period', (tester) async {
    final viewModel = await pumpDetails(tester);

    final monthDays = viewModel.days.length;

    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();

    expect(find.text('This Week'), findsOneWidget);

    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();

    expect(viewModel.days.length, lessThan(monthDays));
    expect(find.text('This Week'), findsOneWidget);
  });

  testWidgets('edit habit sheet saves the updated habit', (tester) async {
    final viewModel = await pumpDetails(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Habit'), findsOneWidget);
    expect(find.text('Habit Name'), findsOneWidget);
    expect(find.text('Target & Unit'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Training');
    await tester.pump();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(viewModel.habitTitle, 'Training');
    expect(find.text('Training'), findsOneWidget);
  });
}
