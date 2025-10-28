/// Local storage keys for SharedPreferences, Hive, etc.
class StorageKeys {
  StorageKeys._();

  // Auth
  static const String authToken = 'auth_token'; // JWT Token
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userData = 'user_data';

  // Settings
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String fontSize = 'font_size';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricsEnabled = 'biometrics_enabled';

  // Onboarding
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String onboardingVersion = 'onboarding_version';

  // Cache
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedUserData = 'cached_user_data';
  static const String cachedProducts = 'cached_products';

  // App State
  static const String lastOpenedPage = 'last_opened_page';
  static const String appOpenCount = 'app_open_count';
  static const String lastAppVersion = 'last_app_version';

  // Preferences
  static const String preferredCurrency = 'preferred_currency';
  static const String preferredPaymentMethod = 'preferred_payment_method';
  static const String autoBackup = 'auto_backup';
}