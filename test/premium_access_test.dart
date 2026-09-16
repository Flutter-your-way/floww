import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/services/premium_service.dart';

import 'support/fake_services.dart';

void main() {
  group('plan catalog', () {
    test('exposes exactly the monthly and yearly plans', () {
      expect(PremiumService.plans.length, 2);

      final monthly = PremiumService.catalog.planFor(SubscriptionTerm.monthly);
      expect(monthly.planId, AppSubscription.monthlyPlanId);
      expect(monthly.price, 499);
      expect(monthly.periodLabel, '/month');

      final yearly = PremiumService.catalog.planFor(SubscriptionTerm.yearly);
      expect(yearly.planId, AppSubscription.yearlyPlanId);
      expect(yearly.price, 3999);
      expect(yearly.periodLabel, '/year');
    });
  });

  group('subscription fields on the user document', () {
    test('round-trips every stored field', () {
      final subscription = buildSubscription(
        term: SubscriptionTerm.monthly,
        price: AppSubscription.monthlyPrice,
        periodLabel: '/month',
        planLabel: 'Monthly Plan',
        startedAt: DateTime(2026, 1, 12),
        renewsOn: DateTime(2026, 2, 12),
        trialEndsOn: DateTime(2026, 1, 19),
      );

      final fields = subscription.toUserFields();
      expect(fields[SubscriptionFields.isPremium], isTrue);
      expect(fields[SubscriptionFields.planName], 'Monthly Plan');

      final section = SubscriptionEntity.sectionOf(fields)!;
      expect(section[SubscriptionFields.planId], AppSubscription.monthlyPlanId);
      expect(section[SubscriptionFields.currency], AppSubscription.currency);
      expect(section[SubscriptionFields.price], 499);
      expect(
        section[SubscriptionFields.trialEndsOn],
        '2026-01-19T00:00:00.000',
      );

      final restored = SubscriptionEntity.fromUser('test-uid', fields);
      expect(restored.planId, subscription.planId);
      expect(restored.term, SubscriptionTerm.monthly);
      expect(restored.trialEndsOn, subscription.trialEndsOn);
      expect(restored.renewsOn, subscription.renewsOn);
    });

    test('lives alongside the rest of the user document', () {
      final user = {
        'uid': 'test-uid',
        'email': 'wave@floww.app',
        'displayName': 'Wave',
        ...buildSubscription(term: SubscriptionTerm.yearly).toUserFields(),
      };

      expect(SubscriptionEntity.isStoredOn(user), isTrue);

      final restored = SubscriptionEntity.fromUser('test-uid', user);
      expect(restored.term, SubscriptionTerm.yearly);
      expect(user['displayName'], 'Wave');
    });

    test('a user document without subscription fields has no plan', () {
      expect(SubscriptionEntity.isStoredOn(null), isFalse);
      expect(SubscriptionEntity.isStoredOn({'uid': 'test-uid'}), isFalse);
      expect(
        SubscriptionEntity.isStoredOn({
          SubscriptionFields.subscription: {
            SubscriptionFields.status: SubscriptionStatus.none.name,
          },
        }),
        isFalse,
      );
    });

    test('reads documents written before planId existed', () {
      final subscription = buildSubscription(term: SubscriptionTerm.yearly);
      final section = subscription.toSection()
        ..remove(SubscriptionFields.planId)
        ..remove(SubscriptionFields.currency)
        ..remove(SubscriptionFields.trialEndsOn);
      final fields = {
        ...subscription.toUserFields(),
        SubscriptionFields.subscription: section,
      };

      final restored = SubscriptionEntity.fromUser('test-uid', fields);
      expect(restored.planId, AppSubscription.yearlyPlanId);
      expect(restored.currency, AppSubscription.currency);
      expect(restored.trialEndsOn, isNull);
    });

    test('cancelling only touches the subscription status fields', () {
      final fields = SubscriptionEntity.cancelledFields(DateTime(2026, 3, 1));

      expect(
        fields[SubscriptionFields.path(SubscriptionFields.status)],
        SubscriptionStatus.cancelled.name,
      );
      expect(
        fields.keys,
        everyElement(startsWith('${SubscriptionFields.subscription}.')),
      );
      expect(fields.containsKey(SubscriptionFields.isPremium), isFalse);
    });
  });

  group('access', () {
    test('an active plan grants access until the renewal date', () {
      final subscription = buildSubscription(
        startedAt: DateTime(2026, 1, 12),
        renewsOn: DateTime(2027, 1, 12),
      );

      expect(subscription.hasAccess(DateTime(2026, 6, 1)), isTrue);
      expect(subscription.hasAccess(DateTime(2027, 1, 13)), isFalse);
    });

    test('a cancelled plan keeps access until the period ends', () {
      final subscription = buildSubscription(
        status: SubscriptionStatus.cancelled,
        term: SubscriptionTerm.monthly,
        renewsOn: DateTime(2026, 2, 12),
      );

      expect(subscription.hasAccess(DateTime(2026, 2, 1)), isTrue);
      expect(subscription.hasAccess(DateTime(2026, 2, 13)), isFalse);
    });

    test('the trial window is reported while it lasts', () {
      final subscription = buildSubscription(
        startedAt: DateTime(2026, 1, 12),
        trialEndsOn: DateTime(2026, 1, 19),
      );

      expect(subscription.isInTrial(DateTime(2026, 1, 15)), isTrue);
      expect(subscription.isInTrial(DateTime(2026, 1, 20)), isFalse);
    });
  });

  group('PremiumAccessProvider', () {
    test('a user without a subscription is locked out', () async {
      final provider = PremiumAccessProvider(FakePremiumService())..start();
      addTearDown(provider.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isFalse);
      expect(provider.hasAccess, isFalse);
      expect(provider.term, isNull);
      expect(provider.canUse(PremiumCapability.waveCoach), isFalse);
      expect(provider.canUse(PremiumCapability.habitTracking), isTrue);
    });

    test('each plan unlocks premium capabilities', () async {
      for (final term in SubscriptionTerm.values) {
        final service = FakePremiumService();
        await service.subscribe(term, from: DateTime.now());

        final provider = PremiumAccessProvider(service)..start();
        addTearDown(provider.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(provider.hasAccess, isTrue, reason: term.name);
        expect(provider.term, term);
        expect(provider.planId, term.planId);
        expect(provider.isTrialing, isTrue);
        expect(provider.canUse(PremiumCapability.advancedAnalytics), isTrue);
      }
    });

    test('an elapsed plan no longer grants access', () async {
      final service = FakePremiumService(
        subscription: buildSubscription(
          term: SubscriptionTerm.monthly,
          startedAt: DateTime(2024, 1, 12),
          renewsOn: DateTime(2024, 2, 12),
        ),
      );

      final provider = PremiumAccessProvider(service)..start();
      addTearDown(provider.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(provider.isActive, isTrue);
      expect(provider.hasAccess, isFalse);
      expect(provider.canUse(PremiumCapability.waveCoach), isFalse);
    });
  });
}
