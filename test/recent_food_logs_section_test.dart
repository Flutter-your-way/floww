import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/recent_food_logs_section.dart';

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

  final item = RecentFoodItem(
    log: FoodLog(
      food: const CatalogFood(
        name: 'Chicken Breast',
        serving: '100g',
        weightG: 100,
        calories: 165,
        proteinG: 31,
        carbsG: 0,
        fatG: 4,
      ).toFoodModel(id: 'a', userId: 'u', createdAt: DateTime(2026)),
      mealType: MealType.breakfast,
      loggedAt: DateTime(2026),
    ),
    name: 'Chicken Breast',
    caloriesLabel: '165 kcal',
  );

  Future<void> pumpSection(
    WidgetTester tester, {
    required ValueChanged<RecentFoodItem> onTap,
    VoidCallback? onViewAll,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: Scaffold(
          body: RecentFoodLogsSection(
            items: [item],
            onTap: onTap,
            onViewAll: onViewAll,
          ),
        ),
      ),
    );
  }

  testWidgets('section label is black', (tester) async {
    await pumpSection(tester, onTap: (_) {});

    final label = tester.widget<Text>(find.text('RECENT FOOD LOGS'));
    expect(label.style?.color, const Color(0xFF181818));
  });

  testWidgets('view all is offered and reports taps', (tester) async {
    var viewAllTaps = 0;
    await pumpSection(
      tester,
      onTap: (_) {},
      onViewAll: () => viewAllTaps++,
    );

    await tester.tap(find.text('View all'));
    expect(viewAllTaps, 1);
  });

  testWidgets('view all is hidden when no handler is given', (tester) async {
    await pumpSection(tester, onTap: (_) {});

    expect(find.text('View all'), findsNothing);
  });

  testWidgets('tapping a chip reports the item', (tester) async {
    final tapped = <RecentFoodItem>[];
    await pumpSection(tester, onTap: tapped.add);

    await tester.tap(find.text('Chicken Breast'));
    expect(tapped, [item]);
  });
}
