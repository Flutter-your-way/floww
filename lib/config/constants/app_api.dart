class AppApi {
  AppApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-floww-fitness.cloudfunctions.net',
  );

  static const String foodScan = '/scanFood';
  static const String foodSearch = '/searchFood';
  static const String foodDescribe = '/describeFood';
  static const String waveChat = '/waveChat';
  static const String account = '/deleteAccount';
  static const String completeWorkout = '/completeWorkout';
  static const String unlogWorkout = '/unlogWorkout';
  static const String submitOnboarding = '/submitOnboarding';
  static const String completeOnboarding = '/completeOnboarding';
  static const String subscribePremium = '/subscribePremium';
  static const String cancelPremium = '/cancelPremium';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration searchResponseTimeout = Duration(seconds: 20);
  static const Duration aiResponseTimeout = Duration(seconds: 120);
  static const Duration accountDeleteTimeout = Duration(seconds: 90);
  static const Duration actionResponseTimeout = Duration(seconds: 30);

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
