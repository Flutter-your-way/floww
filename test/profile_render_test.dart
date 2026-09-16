import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/view_models/profile_view_model.dart';
import 'package:floww/core/profile/views/profile_view.dart';
import 'package:floww/core/profile/widgets/profile_log_out_button.dart';
import 'package:floww/navigation/app_router.dart';

import 'support/fake_services.dart';

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

  Future<ProfileViewModel> pumpProfile(
    WidgetTester tester,
    ProfileAccount account,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 2200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final viewModel = ProfileViewModel(
      FakeProfileService(account: account),
      FakeAuthService(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(AppThemeMode.flow),
        home: ChangeNotifierProvider<ProfileViewModel>.value(
          value: viewModel,
          child: const ProfileView(),
        ),
      ),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets('profile renders the signed-in user data', (tester) async {
    await pumpProfile(tester, buildAccount());

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Von Doe'), findsOneWidget);
    expect(find.text('Lose Fat · Intermediate'), findsOneWidget);

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('178'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('76'), findsOneWidget);
    expect(find.text('Diet'), findsOneWidget);
    expect(find.text('Flexible'), findsOneWidget);

    expect(find.text('Daily Targets'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('10,000'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('2.5'), findsOneWidget);
    expect(find.text('Edit'), findsNWidgets(2));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connected Apps & Devices'), findsOneWidget);
    expect(find.text('Currently: Metric (kg, cm)'), findsOneWidget);
    expect(find.text('Privacy & Data'), findsOneWidget);

    expect(find.byType(ProfileLogOutButton), findsOneWidget);
    expect(find.text('Floww · v1.0'), findsOneWidget);
  });

  testWidgets('missing onboarding values render as placeholders', (
    tester,
  ) async {
    final viewModel = await pumpProfile(tester, ProfileAccount.empty);

    expect(find.text('Your Profile'), findsOneWidget);
    expect(find.text('Complete your onboarding'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(6));
    expect(viewModel.summary.initial, '?');
  });

  testWidgets('imperial accounts render converted measurements', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      buildAccount(unitSystem: MeasurementSystem.imperial),
    );

    expect(find.text('70.1'), findsOneWidget);
    expect(find.text('in'), findsOneWidget);
    expect(find.text('167.6'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);
    expect(find.text('Currently: Imperial (lbs, in)'), findsOneWidget);
  });

  testWidgets('a user without a plan sees the live trial countdown', (
    tester,
  ) async {
    final viewModel = await pumpProfile(
      tester,
      buildAccount(
        memberSince: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );

    expect(find.text('FLOWW PREMIUM'), findsOneWidget);
    expect(find.text('Free trial active · 5 days remaining'), findsOneWidget);
    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.byType(AppStatusChip), findsNothing);

    expect(viewModel.summary.isPremium, isFalse);
    expect(viewModel.subscriptionRoute, AppRouter.premiumUpgrade);
  });

  testWidgets('an expired trial drops back to the free plan message', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      buildAccount(
        memberSince: DateTime.now().subtract(const Duration(days: 30)),
      ),
    );

    expect(
      find.text('Free plan · Unlock the full WAVE experience'),
      findsOneWidget,
    );
  });

  testWidgets('an active subscription renders the manage card', (tester) async {
    final viewModel = await pumpProfile(
      tester,
      buildAccount(subscription: buildSubscription()),
    );

    expect(find.text('FLOWW PREMIUM'), findsOneWidget);
    expect(
      find.text('All features unlocked · Renews Aug 2026'),
      findsOneWidget,
    );
    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('PREMIUM'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.byType(AppStatusChip), findsNWidgets(2));
    expect(find.text('Upgrade to Premium'), findsNothing);

    expect(viewModel.summary.isPremium, isTrue);
    expect(viewModel.subscriptionRoute, AppRouter.premium);
  });

  testWidgets('a cancelled subscription keeps access until the renewal date', (
    tester,
  ) async {
    final viewModel = await pumpProfile(
      tester,
      buildAccount(
        subscription: buildSubscription(
          status: SubscriptionStatus.cancelled,
          renewsOn: DateTime(2026, 8, 12),
        ),
      ),
    );

    expect(find.text('Cancelled · Access until Aug 12, 2026'), findsOneWidget);
    expect(find.text('Resume Premium'), findsOneWidget);
    expect(viewModel.subscriptionRoute, AppRouter.premium);
  });

  testWidgets('logging out signs the user out through the auth service', (
    tester,
  ) async {
    final authService = FakeAuthService();
    final viewModel = ProfileViewModel(FakeProfileService(), authService);
    addTearDown(viewModel.dispose);
    await tester.pump();

    expect(await viewModel.logOut(), isTrue);
    expect(authService.didSignOut, isTrue);
    expect(viewModel.isSigningOut, isFalse);
  });

  testWidgets('every settings row carries a route target', (tester) async {
    final viewModel = await pumpProfile(tester, buildAccount());

    expect(viewModel.settings.length, 4);
    for (final item in viewModel.settings) {
      expect(item.route, startsWith('/'));
    }
  });
}
