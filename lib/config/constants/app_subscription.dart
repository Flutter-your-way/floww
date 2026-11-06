class AppSubscription {
  AppSubscription._();

  static const String monthlyPlanId = 'floww_premium_monthly';
  static const String yearlyPlanId = 'floww_premium_yearly';

  static const int monthlyDurationMonths = 1;
  static const int yearlyDurationMonths = 12;

  static const String entitlementId = 'premium';

  static const String revenueCatAppleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'appl_fiOgoXWsskOiASStDnflbHaeQly',
  );
  static const String revenueCatGoogleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
  );

  static const String appleManageUrl =
      'https://apps.apple.com/account/subscriptions';
  static const String googleManageUrl =
      'https://play.google.com/store/account/subscriptions';

  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue:
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
  );
  static const String privacyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
}
