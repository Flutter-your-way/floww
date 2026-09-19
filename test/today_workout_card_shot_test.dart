import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/widgets/today_workout_card.dart';

const _out =
    '/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/04215e93-0897-4a70-861a-372576aef92f/scratchpad';

const _shotKey = ValueKey('shot');

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

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shotKey),
  );
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

Future<void> _pump(WidgetTester tester, Widget card) async {
  tester.view.physicalSize = const Size(393, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.buildTheme(AppThemeMode.flow),
      home: RepaintBoundary(
        key: _shotKey,
        child: ColoredBox(
          color: const Color(0xFF0A0A0A),
          child: Padding(padding: const EdgeInsets.all(16), child: card),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('today workout card completed shot', (tester) async {
    await _pump(
      tester,
      const Align(
        alignment: Alignment.topCenter,
        child: TodayWorkoutCard(
          completed: CompletedWorkout(
            sessionId: 'session-1',
            title: 'Shoulders & Core',
            completedLabel: 'Completed at 7:42 AM',
            stats: [
              CompletedWorkoutStat(
                label: 'Duration',
                value: '45',
                unit: 'min',
              ),
              CompletedWorkoutStat(label: 'Sets', value: '18', unit: 'total'),
              CompletedWorkoutStat(
                label: 'Calories',
                value: '1,240',
                unit: 'kcal',
              ),
            ],
            highlights: [
              '+40 Flow points earned',
              '2 personal records',
              'Muscle Hypertrophy Program · Week 1',
            ],
          ),
        ),
      ),
    );
    await _shot(tester, 'today_workout_completed');

    expect(tester.takeException(), isNull);
  });

  testWidgets('today workout card planned shot', (tester) async {
    await _pump(
      tester,
      const Align(
        alignment: Alignment.topCenter,
        child: TodayWorkoutCard(
          workout: WorkoutRecommendation(
            title: 'Shoulders & Core',
            durationLabel: '45m',
            intensityLabel: 'Moderate Intensity',
            reasons: [
              'Trained earlier today',
              'Muscle Hypertrophy Program · Week 1',
            ],
          ),
        ),
      ),
    );
    await _shot(tester, 'today_workout_planned');

    expect(tester.takeException(), isNull);
  });
}
