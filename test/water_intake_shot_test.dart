import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/water_log.dart';
import 'package:floww/core/nutrition/view_models/water_intake_view_model.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/core/nutrition/views/water_intake_sheet.dart';
import 'package:floww/navigation/services/navigation_service.dart';

import 'fakes/fake_nutrition_log_service.dart';

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

void main() {
  setUpAll(_loadFonts);

  testWidgets('water intake shot', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final service = FakeNutritionLogService();
    const entries = [
      [250, 8, 30],
      [500, 10, 15],
      [330, 12, 0],
      [250, 15, 0],
      [450, 17, 30],
      [320, 20, 0],
    ];
    for (var i = 0; i < entries.length; i++) {
      service.waterLogs.add(
        WaterLog(
          id: 'w$i',
          amountMl: entries[i][0].toDouble(),
          loggedAt: date.add(
            Duration(hours: entries[i][1], minutes: entries[i][2]),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: RepaintBoundary(
            child: ChangeNotifierProvider(
              create: (_) => WaterIntakeViewModel(
                service,
                date,
                NutritionGoal.defaults,
              ),
              child: const AppFloatingSheet(child: WaterIntakeSheet()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/c6c3da86-1e1a-4fc0-8a79-292559166bc4/scratchpad/water.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });

  testWidgets('nutrition points shot', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: const Scaffold(
          backgroundColor: Color(0xFF0A0A0A),
          body: RepaintBoundary(
            child: AppInfoSheet(
              title: 'Nutrition',
              message:
                  'Your nutrition log earns Flow Points (5/25). Every meal you '
                  'log brings you closer to your daily Flow Score goal.\n'
                  'Above 20 is excellent — keep it up!',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/c6c3da86-1e1a-4fc0-8a79-292559166bc4/scratchpad/points.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
