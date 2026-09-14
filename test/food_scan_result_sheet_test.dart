import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/view_models/food_scan_result_view_model.dart';
import 'package:floww/core/nutrition/views/food_scan_result_sheet.dart';
import 'package:floww/navigation/services/navigation_service.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  late FoodModel food;

  setUpAll(() {
    food = FoodModel.fromJson(
      jsonDecode(File('test/fixtures/food_model.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  Future<FakeNutritionLogService> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final service = FakeNutritionLogService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: const Scaffold(),
      ),
    );
    showAppFloatingSheet<void>(
      context: tester.element(find.byType(Scaffold)),
      builder: (_) => ChangeNotifierProvider(
        create: (_) => FoodScanResultViewModel(
          food,
          NutritionGoal.defaults,
          service,
          DateTime.now(),
        ),
        child: const FoodScanResultSheet(),
      ),
    );
    await tester.pumpAndSettle();
    return service;
  }

  testWidgets('edits flow back into the review and get saved', (tester) async {
    final service = await openSheet(tester);

    expect(find.text('AI Food Scan'), findsOneWidget);
    expect(find.text('Grilled chicken rice bowl (estimated)'), findsOneWidget);

    await tester.tap(find.text('Edit Meal'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Nutrients'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Grilled chicken rice bowl'),
      'Chicken bowl',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '567'), '480');
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Chicken bowl'), findsOneWidget);
    expect(find.text('480'), findsOneWidget);

    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();

    final saved = service.foodLogs.single;
    expect(saved.food.name, 'Chicken bowl');
    expect(saved.macros.calories, 480);
    expect(find.byType(FoodScanResultSheet), findsNothing);
  });

  testWidgets('system back while editing returns to the review', (
    tester,
  ) async {
    final service = await openSheet(tester);

    await tester.tap(find.text('Edit Meal'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('AI Food Scan'), findsOneWidget);
    expect(find.text('Edit Nutrients'), findsNothing);
    expect(service.foodLogs, isEmpty);
  });

  testWidgets('closing the sheet discards without saving', (tester) async {
    final service = await openSheet(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(service.foodLogs, isEmpty);
    expect(find.byType(FoodScanResultSheet), findsNothing);
  });
}
