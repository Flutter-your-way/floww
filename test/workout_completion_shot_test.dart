import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/workout/views/recovery_check_in_sheet.dart';
import 'package:floww/core/workout/views/workout_complete_sheet.dart';
import 'package:floww/core/workout/views/workout_share_sheet.dart';
import 'package:floww/navigation/services/navigation_service.dart';

import 'fakes/fake_workout_session_service.dart';

const _out =
    '/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/82d895d7-8538-4206-bbac-1be805e42e00/scratchpad';

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

const _shotKey = ValueKey('shot');

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shotKey),
  );
  final image = await boundary.toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

WorkoutCompletionViewModel _viewModel() {
  final session = WorkoutFixtures.session();
  return WorkoutCompletionViewModel(
    FakeWorkoutSessionService(session),
    WorkoutCompletionResult(
      session: session,
      flowScoreBefore: session.flowScoreBefore,
      flowScoreAfter: session.flowScoreAfter,
    ),
  );
}

Future<void> _pumpSheet(WidgetTester tester, Widget sheet) async {
  tester.view.physicalSize = const Size(393, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.buildTheme(AppThemeMode.flow),
      navigatorKey: NavigationService.navigatorKey,
      home: RepaintBoundary(
        key: _shotKey,
        child: ColoredBox(color: const Color(0xFF0A0A0A), child: sheet),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('workout complete sheet shot', (tester) async {
    await _pumpSheet(
      tester,
      ChangeNotifierProvider.value(
        value: _viewModel(),
        child: const WorkoutCompleteSheet(),
      ),
    );
    await _shot(tester, 'workout_complete_sheet');

    expect(tester.takeException(), isNull);
  });

  testWidgets('workout share sheet shot', (tester) async {
    await _pumpSheet(
      tester,
      ChangeNotifierProvider.value(
        value: _viewModel(),
        child: const WorkoutShareSheet(),
      ),
    );
    await _shot(tester, 'workout_share_sheet_page_1');

    await tester.drag(find.byType(PageView), const Offset(-393, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await _shot(tester, 'workout_share_sheet_page_2');

    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery check in sheet shot', (tester) async {
    final viewModel = _viewModel();
    await _pumpSheet(
      tester,
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const RecoveryCheckInSheet(),
      ),
    );
    await tester.tap(find.text('Great'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _shot(tester, 'recovery_check_in_sheet');

    expect(tester.takeException(), isNull);
  });
}
