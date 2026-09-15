import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/workout/services/workout_service.dart';
import 'package:floww/core/workout/view_models/workout_details_view_model.dart';
import 'package:floww/core/workout/views/workout_details_view.dart';
import 'package:floww/navigation/services/navigation_service.dart';

const _out =
    '/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/'
    '529a5049-5385-47d2-9715-2e073997fa5a/scratchpad';

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
    find.byType(RepaintBoundary).first,
  );
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('workout details shot', (tester) async {
    tester.view.physicalSize = const Size(393, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        navigatorKey: NavigationService.navigatorKey,
        home: RepaintBoundary(
          child: ChangeNotifierProvider(
            create: (_) => WorkoutDetailsViewModel(
              const WorkoutService(),
              'leg-day-today',
            ),
            child: const WorkoutDetailsView(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await _shot(tester, 'workout_details');

    expect(tester.takeException(), isNull);
  });
}
