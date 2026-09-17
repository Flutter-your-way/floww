import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/view_models/habit_calendar_view_model.dart';
import 'package:floww/core/habits/views/habit_calendar_view.dart';

import 'fakes/fake_habit_service.dart';

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

  testWidgets('habit calendar renders and changes month', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);
    final service = FakeHabitService(
      habits: [
        HabitDefinition(
          id: 'meditation',
          title: 'Meditation',
          target: 10,
          metric: HabitMetric.minutes,
          icon: HabitIconKind.meditation,
          createdAt: AppDateUtils.addDays(today, -20),
          sortOrder: 0,
        ),
      ],
      days: [
        HabitDayLog(
          date: today,
          entries: const [
            HabitLogEntry(
              id: 'meditation',
              title: 'Meditation',
              value: 10,
              target: 10,
              metric: 'minutes',
            ),
          ],
        ),
      ],
    );
    addTearDown(service.dispose);

    final viewModel = HabitCalendarViewModel(service, now);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const HabitCalendarView(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Habit Calendar'), findsOneWidget);
    expect(find.text(AppDateUtils.monthYear(now)), findsOneWidget);
    expect(find.text('Best Streak'), findsOneWidget);
    expect(find.text('Habit Streaks'), findsOneWidget);

    viewModel.previousMonth();
    await tester.pump();

    expect(
      find.text(AppDateUtils.monthYear(DateTime(now.year, now.month - 1))),
      findsOneWidget,
    );
  });
}
