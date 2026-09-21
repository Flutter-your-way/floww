import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/services/profile_avatar_service.dart';
import 'package:floww/core/profile/view_models/edit_daily_targets_view_model.dart';
import 'package:floww/core/profile/view_models/edit_personal_info_view_model.dart';
import 'package:floww/core/profile/views/edit_daily_targets_view.dart';
import 'package:floww/core/profile/views/edit_personal_info_view.dart';

import 'support/fake_services.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.buildTheme(AppThemeMode.flow), home: child),
  );
  await tester.pumpAndSettle();
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

  Future<EditPersonalInfoViewModel> pumpPersonalInfo(
    WidgetTester tester,
    FakeProfileService service,
  ) async {
    final viewModel = EditPersonalInfoViewModel(service, ProfileAvatarService());
    addTearDown(viewModel.dispose);

    await _pump(
      tester,
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const EditPersonalInfoView(),
      ),
    );
    return viewModel;
  }

  Future<EditDailyTargetsViewModel> pumpDailyTargets(
    WidgetTester tester,
    FakeProfileService service,
  ) async {
    final viewModel = EditDailyTargetsViewModel(service);
    addTearDown(viewModel.dispose);

    await _pump(
      tester,
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const EditDailyTargetsView(),
      ),
    );
    return viewModel;
  }

  testWidgets('edit personal information renders the stored profile', (
    tester,
  ) async {
    final viewModel = await pumpPersonalInfo(tester, FakeProfileService());

    expect(find.text('Edit Personal Information'), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Von Doe'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('178'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('Current Weight'), findsOneWidget);
    expect(find.text('76'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('Primary Goal'), findsOneWidget);
    expect(find.text('Diet Preference'), findsOneWidget);
    expect(find.text('Training Experience'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    expect(viewModel.goalGroup.selectedId, 'Lose Fat');
    expect(viewModel.dietGroup.selectedId, 'Flexible');
    expect(viewModel.experienceGroup.selectedId, 'Intermediate');
  });

  testWidgets('an imperial profile loads converted values', (tester) async {
    final viewModel = await pumpPersonalInfo(
      tester,
      FakeProfileService(
        account: buildAccount(unitSystem: MeasurementSystem.imperial),
      ),
    );

    expect(viewModel.heightUnit, HeightUnit.inches);
    expect(viewModel.weightUnit, WeightUnit.lbs);
    expect(find.text('70.1'), findsOneWidget);
    expect(find.text('167.6'), findsOneWidget);
  });

  testWidgets('selecting a goal moves the selection', (tester) async {
    final viewModel = await pumpPersonalInfo(tester, FakeProfileService());

    expect(viewModel.goalGroup.selectedId, 'Lose Fat');

    await tester.tap(find.text('Gain Muscle'));
    await tester.pump();

    expect(viewModel.goalGroup.selectedId, 'Gain Muscle');
  });

  testWidgets('save is disabled while a required field is empty', (
    tester,
  ) async {
    final viewModel = await pumpPersonalInfo(tester, FakeProfileService());

    expect(viewModel.canSave, isTrue);

    await tester.enterText(find.text('178'), '');
    await tester.pump();

    expect(viewModel.canSave, isFalse);
  });

  testWidgets('saving writes the draft back through the service', (
    tester,
  ) async {
    final service = FakeProfileService();
    final viewModel = await pumpPersonalInfo(tester, service);

    await tester.enterText(find.text('Von Doe'), 'Ada Doe');
    await tester.pump();

    expect(await viewModel.save(), isTrue);
    expect(service.savedPersonalInformation?.name, 'Ada Doe');
    expect(service.savedPersonalInformation?.heightValue, 178);
    expect(service.savedPersonalInformation?.goalId, 'Lose Fat');
  });

  testWidgets('edit daily targets renders the stored targets', (tester) async {
    await pumpDailyTargets(tester, FakeProfileService());

    expect(find.text('Edit Daily Targets'), findsOneWidget);
    expect(
      find.text(
        'WAVE adjusts these targets based on your activity. '
        'You can always override.',
      ),
      findsOneWidget,
    );
    expect(find.text('Daily Steps'), findsOneWidget);
    expect(find.text('10,000'), findsOneWidget);
    expect(find.text('steps'), findsOneWidget);
    expect(find.text('Sleep Goal'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('hrs/night'), findsOneWidget);
    expect(find.text('Water Intake'), findsOneWidget);
    expect(find.text('2.5'), findsOneWidget);
    expect(find.text('liters'), findsOneWidget);
    expect(find.text('Save Targets'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(3));
  });

  testWidgets('target values snap to the slider step', (tester) async {
    final viewModel = await pumpDailyTargets(tester, FakeProfileService());

    viewModel.updateTarget(DailyTarget.steps, 12340);
    await tester.pump();

    expect(find.text('12,500'), findsOneWidget);

    viewModel.updateTarget(DailyTarget.sleep, 7.4);
    await tester.pump();

    expect(find.text('7.5'), findsOneWidget);
  });

  testWidgets('saving targets writes every value through the service', (
    tester,
  ) async {
    final service = FakeProfileService();
    final viewModel = await pumpDailyTargets(tester, service);

    viewModel.updateTarget(DailyTarget.water, 3.4);
    await tester.pump();

    expect(await viewModel.save(), isTrue);
    expect(service.savedDailyTargets?.valueOf(DailyTarget.steps), 10000);
    expect(service.savedDailyTargets?.valueOf(DailyTarget.sleep), 8);
    expect(service.savedDailyTargets?.valueOf(DailyTarget.water), 3.5);
  });
}
