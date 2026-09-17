import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';
import 'package:floww/core/recovery/view_models/muscle_recovery_view_model.dart';
import 'package:floww/core/recovery/views/muscle_recovery_list_sheet.dart';
import 'package:floww/core/recovery/views/muscle_recovery_view.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/navigation/services/navigation_service.dart';

const _out =
    '/private/tmp/claude-501/-Users-shobhit-FlutterYourWay-floww/1dac875b-372e-4939-8efc-e5a6f38af322/scratchpad';

class _StubSessionService implements WorkoutSessionService {
  _StubSessionService(this.sessions);

  final List<WorkoutSessionEntity> sessions;

  @override
  Stream<List<WorkoutSessionEntity>> watchRecentSessions() =>
      Stream.value(sessions);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

WorkoutSessionEntity _session({
  required String id,
  required Duration ago,
  required double trainingEffect,
  required List<MuscleShareEntry> muscles,
}) {
  final completedAt = DateTime.now().subtract(ago);
  return WorkoutSessionEntity(
    id: id,
    workoutId: id,
    name: id,
    date: completedAt,
    status: WorkoutSessionStatus.completed,
    startedAt: completedAt.subtract(const Duration(hours: 1)),
    completedAt: completedAt,
    durationSeconds: 3600,
    exercises: const [],
    trainingEffect: trainingEffect,
    muscleActivation: muscles,
  );
}

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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('muscle recovery shot', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final viewModel = MuscleRecoveryViewModel(
      MuscleRecoveryService(
        sessionService: _StubSessionService([
          _session(
            id: 'push',
            ago: const Duration(minutes: 2),
            trainingEffect: 4.2,
            muscles: const [
              MuscleShareEntry(name: 'Chest', share: 0.82),
              MuscleShareEntry(name: 'Shoulders', share: 0.42),
              MuscleShareEntry(name: 'Triceps', share: 0.34),
              MuscleShareEntry(name: 'Traps', share: 0.46),
            ],
          ),
          _session(
            id: 'legs',
            ago: const Duration(hours: 30),
            trainingEffect: 4.5,
            muscles: const [
              MuscleShareEntry(name: 'Quadriceps', share: 0.95),
              MuscleShareEntry(name: 'Glutes', share: 0.6),
              MuscleShareEntry(name: 'Hamstrings', share: 0.4),
              MuscleShareEntry(name: 'Calves', share: 0.25),
              MuscleShareEntry(name: 'Abdominals', share: 0.45),
            ],
          ),
        ]),
      ),
      MuscleMapService(),
    );

    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          theme: AppTheme.buildTheme(AppThemeMode.flow),
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          home: ChangeNotifierProvider<MuscleRecoveryViewModel>.value(
            value: viewModel,
            child: const MuscleRecoveryView(),
          ),
        ),
      ),
    );
    await _ready(tester);
    expect(viewModel.isReady, isTrue);
    await _shot(tester, 'recovery_front');

    viewModel.selectSide(MuscleBodySide.back);
    await _ready(tester);
    await _shot(tester, 'recovery_back');

    await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
    await _ready(tester);
    expect(find.byType(MuscleRecoveryListSheet), findsOneWidget);
    await _shot(tester, 'recovery_sheet');
  });
}
