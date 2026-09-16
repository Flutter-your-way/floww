import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';
import 'package:floww/core/settings/view_models/connected_apps_view_model.dart';
import 'package:floww/core/settings/view_models/notification_settings_view_model.dart';
import 'package:floww/core/settings/view_models/privacy_data_view_model.dart';
import 'package:floww/core/settings/view_models/units_view_model.dart';
import 'package:floww/core/settings/views/connected_apps_view.dart';
import 'package:floww/core/settings/views/notification_settings_view.dart';
import 'package:floww/core/settings/views/privacy_data_view.dart';
import 'package:floww/core/settings/views/units_view.dart';

import 'support/fake_services.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
}

Future<void> _pumpView<T extends ChangeNotifier>(
  WidgetTester tester,
  T viewModel,
  Widget view,
) async {
  tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.buildTheme(AppThemeMode.flow),
      home: ChangeNotifierProvider<T>.value(value: viewModel, child: view),
    ),
  );
  await tester.pump();
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

  testWidgets('connected apps view lists every integration', (tester) async {
    final viewModel = ConnectedAppsViewModel(const SettingsService());
    await _pumpView(tester, viewModel, const ConnectedAppsView());

    expect(find.text('Connected Apps & Devices'), findsOneWidget);
    expect(find.text('Apple Health'), findsOneWidget);
    expect(find.text('Garmin®'), findsOneWidget);
    expect(find.text('WHOOP'), findsOneWidget);
    expect(find.text('Oura'), findsOneWidget);
    expect(find.text('Fitbit'), findsOneWidget);
    expect(find.text('Health Connect'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Connect'), findsNWidgets(5));

    viewModel.connect('whoop');
    await tester.pump();

    expect(find.text('Connected'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('notification view renders sections and toggles', (tester) async {
    final viewModel = NotificationSettingsViewModel(const SettingsService());
    await _pumpView(tester, viewModel, const NotificationSettingsView());

    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Lifestyle'), findsOneWidget);
    expect(find.text('Wave'), findsOneWidget);
    expect(find.text('Workout Reminder'), findsOneWidget);
    expect(find.text('Streak Alerts'), findsOneWidget);
    expect(find.text('Weekly Summary'), findsOneWidget);

    viewModel.setToggleEnabled('streak_alerts', true);
    await tester.pump();

    final fitness = viewModel.sections.first;
    expect(fitness.items.last.isEnabled, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('units view loads and saves the stored measurement system', (
    tester,
  ) async {
    final profileService = FakeProfileService(
      account: buildAccount(unitSystem: MeasurementSystem.imperial),
    );
    final viewModel = UnitsViewModel(const SettingsService(), profileService);
    await _pumpView(tester, viewModel, const UnitsView());
    await tester.pumpAndSettle();

    expect(find.text('Units & Measurements'), findsOneWidget);
    expect(find.text('Metric'), findsOneWidget);
    expect(find.text('Imperial'), findsOneWidget);
    expect(find.text('Save Preference'), findsOneWidget);
    expect(viewModel.isSelected(MeasurementSystem.imperial), isTrue);

    await tester.tap(find.text('Metric'));
    await tester.pump();

    expect(viewModel.isSelected(MeasurementSystem.metric), isTrue);

    expect(await viewModel.save(), isTrue);
    expect(profileService.savedMeasurementSystem, MeasurementSystem.metric);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });

  testWidgets('privacy view renders the danger zone', (tester) async {
    final viewModel = PrivacyDataViewModel(const SettingsService());
    await _pumpView(tester, viewModel, const PrivacyDataView());

    expect(find.text('Your Data is Safe'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Data Sharing'), findsOneWidget);
    expect(find.text('Danger Zone'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Permanently delete all your data'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    viewModel.dispose();
  });
}
