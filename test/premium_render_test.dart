import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/view_models/premium_upgrade_view_model.dart';
import 'package:floww/core/premium/view_models/premium_view_model.dart';
import 'package:floww/core/premium/views/premium_upgrade_view.dart';
import 'package:floww/core/premium/views/premium_view.dart';

import 'support/fake_services.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  await loader.load();
}

Future<void> _pumpView(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.buildTheme(AppThemeMode.flow), home: child),
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('haptic_feedback'),
          (call) async => false,
        );
  });

  Future<PremiumViewModel> pumpPremium(
    WidgetTester tester,
    FakePremiumService service, {
    FakeInvoicePdfService? pdfService,
    FakeShareService? shareService,
  }) async {
    final viewModel = PremiumViewModel(
      service,
      pdfService ?? FakeInvoicePdfService(),
      shareService ?? FakeShareService(),
    );
    addTearDown(viewModel.dispose);

    await _pumpView(
      tester,
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const PremiumView(),
      ),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    return viewModel;
  }

  Future<PremiumUpgradeViewModel> pumpUpgrade(
    WidgetTester tester,
    FakePremiumService service,
  ) async {
    final viewModel = PremiumUpgradeViewModel(service);
    addTearDown(viewModel.dispose);

    await _pumpView(
      tester,
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const PremiumUpgradeView(),
      ),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    return viewModel;
  }

  testWidgets('premium view renders the active plan from Firestore', (
    tester,
  ) async {
    await pumpPremium(
      tester,
      FakePremiumService(subscription: buildSubscription()),
    );

    expect(find.text('Floww Premium'), findsOneWidget);
    expect(find.text('My Plan'), findsOneWidget);
    expect(find.text('PREMIUM ACTIVE'), findsOneWidget);
    expect(find.text("You're a Floww Pro!"), findsOneWidget);
    expect(find.text('Yearly Plan · ₹3,999/year'), findsOneWidget);
    expect(find.text('Your Active Features'), findsOneWidget);
    expect(find.text('WAVE AI Coach'), findsOneWidget);
    expect(find.text('Renews on · Aug 12, 2026 · ₹3,999/year'), findsOneWidget);
    expect(find.text('Cancel Subscription'), findsOneWidget);
  });

  testWidgets('a user without a plan sees the upgrade prompt', (tester) async {
    await pumpPremium(tester, FakePremiumService());

    expect(find.text('No Active Plan'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Premium Features'), findsOneWidget);
    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.text('Cancel Subscription'), findsNothing);
  });

  testWidgets('premium view renders invoices recorded in Firestore', (
    tester,
  ) async {
    final viewModel = await pumpPremium(
      tester,
      FakePremiumService(
        subscription: buildSubscription(),
        invoices: [
          buildInvoice(id: 'inv_1', paidAt: DateTime(2026, 7, 12)),
          buildInvoice(id: 'inv_2', paidAt: DateTime(2025, 7, 12)),
        ],
      ),
    );

    viewModel.selectTab(PremiumTab.payments);
    await tester.pump();

    expect(find.text('₹7,998'), findsOneWidget);
    expect(find.text('Total paid to date'), findsOneWidget);
    expect(find.text('2 payments'), findsOneWidget);
    expect(find.text('Since Jul 2025'), findsOneWidget);
    expect(find.text('Yearly Plan · Jul 12, 2026'), findsOneWidget);
    expect(find.text('Paid'), findsNWidgets(2));
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Simulated checkout'), findsOneWidget);
  });

  testWidgets('the payments tab is empty until a plan is bought', (
    tester,
  ) async {
    final viewModel = await pumpPremium(tester, FakePremiumService());

    viewModel.selectTab(PremiumTab.payments);
    await tester.pump();

    expect(find.text('No payments yet'), findsNWidgets(2));
    expect(find.text('Export All Invoices'), findsNothing);
  });

  testWidgets('cancelling the subscription writes through the service', (
    tester,
  ) async {
    final service = FakePremiumService(subscription: buildSubscription());
    final viewModel = await pumpPremium(tester, service);

    await tester.tap(find.text('Cancel Subscription'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel Subscription?'), findsOneWidget);
    expect(find.text('Keep Premium'), findsOneWidget);

    await tester.tap(find.text('Cancel Plan'));
    await tester.pumpAndSettle();

    expect(service.didCancel, isTrue);
    expect(viewModel.errorMessage, isNull);
  });

  testWidgets('tapping PDF exports that invoice, export all sends a statement', (
    tester,
  ) async {
    final pdfService = FakeInvoicePdfService();
    final shareService = FakeShareService();
    final viewModel = await pumpPremium(
      tester,
      FakePremiumService(
        subscription: buildSubscription(),
        invoices: [
          buildInvoice(id: 'invoice-1', paidAt: DateTime(2026, 7, 12)),
        ],
      ),
      pdfService: pdfService,
      shareService: shareService,
    );

    viewModel.selectTab(PremiumTab.payments);
    await tester.pump();

    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();

    expect(pdfService.builtInvoice?.id, 'invoice-1');
    expect(shareService.sharedNames, ['invoice.pdf']);

    await tester.tap(find.text('Export All Invoices'));
    await tester.pumpAndSettle();

    expect(pdfService.builtStatement?.length, 1);
    expect(shareService.sharedNames, ['invoice.pdf', 'statement.pdf']);
    expect(viewModel.errorMessage, isNull);
  });

  testWidgets('upgrade view switches between monthly and yearly plans', (
    tester,
  ) async {
    final viewModel = await pumpUpgrade(tester, FakePremiumService());

    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);
    expect(find.text('/month'), findsOneWidget);
    expect(find.text('Start Monthly Plan'), findsOneWidget);
    expect(
      find.text('7-day free trial · Cancel anytime · No commitment'),
      findsOneWidget,
    );
    expect(find.text('BEST VALUE'), findsNothing);

    viewModel.selectTerm(SubscriptionTerm.yearly);
    await tester.pump();

    expect(find.text('BEST VALUE'), findsOneWidget);
    expect(find.text('₹3,999'), findsOneWidget);
    expect(find.text('/year'), findsOneWidget);
    expect(find.text('~₹333/month · Save ₹1,989'), findsOneWidget);
    expect(find.text('Start Yearly Plan'), findsOneWidget);
  });

  testWidgets('purchasing a plan records it and opens the success sheet', (
    tester,
  ) async {
    final service = FakePremiumService();
    final viewModel = await pumpUpgrade(tester, service);

    await tester.tap(find.text('Start Monthly Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Floww Pro Complete!'), findsOneWidget);
    expect(
      find.text('All premium features are unlocked and active on your account.'),
      findsOneWidget,
    );
    expect(find.text('Go Active Plan'), findsOneWidget);
    expect(service.subscribedTerm, SubscriptionTerm.monthly);
    expect(viewModel.purchased?.isActive, isTrue);
    expect(viewModel.purchased?.term, SubscriptionTerm.monthly);
    expect(viewModel.purchased?.isSimulated, isTrue);
  });
}
