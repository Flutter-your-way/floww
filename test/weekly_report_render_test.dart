import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/weekly_report_cards.dart';

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

  testWidgets('weekly report cards render without overflow', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final bars = [
      for (var i = 0; i < days.length; i++)
        ChartBar(
          label: days[i],
          value: [11, 10, 14, 12, 13, 11, 0][i].toDouble(),
          valueLabel: '+${[11, 10, 14, 12, 13, 11, 0][i]}',
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FlowContributionCard(
                pointsLabel: '+7',
                maxLabel: '175',
                progress: 0.41,
                progressLabel: '41% of max this week',
                dailyBars: bars,
              ),
              const SizedBox(height: 16),
              ConsistencyCard(
                daysLogged: '6/7',
                calorieStreak: '0 d',
                proteinStreak: '0 d',
                statuses: const [
                  DayStatusItem(label: 'Mon', status: DayLogStatus.partial),
                  DayStatusItem(label: 'Tue', status: DayLogStatus.full),
                  DayStatusItem(label: 'Wed', status: DayLogStatus.full),
                  DayStatusItem(label: 'Thu', status: DayLogStatus.partial),
                  DayStatusItem(label: 'Fri', status: DayLogStatus.full),
                  DayStatusItem(label: 'Sat', status: DayLogStatus.full),
                  DayStatusItem(label: 'Sun', status: DayLogStatus.none),
                ],
              ),
              const SizedBox(height: 16),
              WeeklyMetricCard(
                title: 'Calories',
                averageLabel: '1,317 avg',
                goalLabel: 'goal 2,450 kcal/day',
                bars: [for (final bar in bars) ChartBar(label: bar.label, value: bar.value)],
                color: const Color(0xFFF97316),
                totalLabel: '7,902',
                weeklyGoalLabel: '17,150',
                progress: 0.46,
              ),
              const SizedBox(height: 16),
              FlowPointsBreakdownCard(
                totalLabel: '71',
                maxLabel: '175',
                rows: const [
                  FlowPointRow(
                    label: 'Calories',
                    detail: 'max 35/wk',
                    pointsLabel: '+9',
                    progress: 0.26,
                  ),
                  FlowPointRow(
                    label: 'Meal Timing',
                    detail: 'max 14/wk',
                    pointsLabel: '+8',
                    progress: 0.57,
                  ),
                ],
                tip: 'Hitting your protein goal every day is the fastest way to '
                    'grow your nutrition Flow contribution — worth up to '
                    '+35 pts/week.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Daily Breakdown'), findsOneWidget);
    expect(find.text('41% of max this week'), findsOneWidget);
  });
}
