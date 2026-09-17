import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/achievements/view_models/achievements_view_model.dart';
import 'package:floww/core/achievements/views/achievements_view.dart';
import 'package:floww/core/achievements/views/streak_achievements_sheet.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/navigation/services/navigation_service.dart';

const _out =
    '/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/6eb19788-27eb-4e61-aeac-5e5e76cdf6a4/scratchpad';

Future<void> _loadFonts() async {
  for (final entry in const {
    'HankenGrotesk': 'assets/fonts/HankenGrotesk-VariableFont_wght.ttf',
    'PlusJakartaSans': 'assets/fonts/PlusJakartaSans-VariableFont_wght.ttf',
    'MaterialIcons':
        '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  }.entries) {
    final loader = FontLoader(entry.key)
      ..addFont(
        Future.value(File(entry.value).readAsBytesSync().buffer.asByteData()),
      );
    await loader.load();
  }
}

Future<void> _ready(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

final _today = AppDateUtils.dateOnly(DateTime.now());

class _StubAchievementsService extends AchievementsService {
  _StubAchievementsService(this.records);

  final AchievementsRecords records;

  @override
  Stream<AchievementsRecords> watchRecords() => Stream.value(records);
}

List<DailyFlowEntry> _flowRun(int days) => [
  for (var offset = days - 1; offset >= 0; offset--)
    DailyFlowEntry(
      date: AppDateUtils.addDays(_today, -offset),
      score: 80,
      workoutScore: 90,
      habitScore: 80,
      nutritionScore: 60,
    ),
];

List<WorkoutSessionEntity> _sessions(int count) => [
  for (var index = 0; index < count; index++)
    WorkoutSessionEntity(
      id: 'session-$index',
      workoutId: 'session-$index',
      name: 'Push Day',
      date: AppDateUtils.addDays(_today, -index),
      status: WorkoutSessionStatus.completed,
      startedAt: AppDateUtils.addDays(_today, -index),
      completedAt: AppDateUtils.addDays(_today, -index),
      durationSeconds: 3600,
      exercises: const [],
      volumeKg: 4000,
      totalSets: 20,
    ),
];

AchievementsRecords _records() => AchievementsRecords(
  flowHistory: _flowRun(9),
  habitDays: [
    for (var offset = 8; offset >= 0; offset--)
      HabitDayLog(
        date: AppDateUtils.addDays(_today, -offset),
        entries: const [
          HabitLogEntry(
            id: 'water',
            title: 'Water Intake',
            value: 2.5,
            target: 2.5,
            metric: 'liters',
          ),
        ],
      ),
  ],
  sessions: _sessions(12),
  nutrition: NutritionLogs.empty,
);

void main() {
  setUpAll(_loadFonts);

  testWidgets('achievements shots', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final viewModel = AchievementsViewModel(
      _StubAchievementsService(_records()),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: RepaintBoundary(
          child: ChangeNotifierProvider<AchievementsViewModel>.value(
            value: viewModel,
            child: const AchievementsView(),
          ),
        ),
      ),
    );
    await _ready(tester);
    await _shot(tester, 'achievements_all');

    expect(viewModel.isReady, isTrue);
    expect(viewModel.totalCount, 18);
    expect(viewModel.unlockedCount, greaterThan(0));
  });

  testWidgets('streak sheet shot', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final summary = AchievementsService().streakSummaryOf(_flowRun(9));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: RepaintBoundary(
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: StreakAchievementsSheet(summary: summary),
            ),
          ),
        ),
      ),
    );
    await _ready(tester);
    expect(find.byType(StreakAchievementsSheet), findsOneWidget);
    await _shot(tester, 'streak_sheet');
  });
}
