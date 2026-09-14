class AppApi {
  AppApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-floww-fitness.cloudfunctions.net/api',
  );

  static const String foodScan = '/food/scan';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration aiResponseTimeout = Duration(seconds: 120);

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
