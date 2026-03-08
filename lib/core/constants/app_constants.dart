/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'OnePOS Admin';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String baseUrl = 'https://01pos2.01technologies.net/api';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // SharedPreferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyIsFirstTime = 'is_first_time';

  // Secure Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
