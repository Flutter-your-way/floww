class AppApi {
  AppApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-floww-fitness.cloudfunctions.net',
  );

  static const String foodScan = '/scanFood';
  static const String account = '/deleteAccount';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration aiResponseTimeout = Duration(seconds: 120);
  static const Duration accountDeleteTimeout = Duration(seconds: 90);

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
