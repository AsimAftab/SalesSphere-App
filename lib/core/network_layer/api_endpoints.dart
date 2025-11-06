/// API Endpoints
/// Centralized location for all API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // ========================================
  // Auth Endpoints
  // ========================================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // ========================================
  // Catalog Endpoints
  // ========================================
  static const String categories = '/categories';
  static const String products = '/products';

  /// Get category by ID
  static String categoryById(String id) => '/categories/$id';

  /// Get products by category
  static String productsByCategory(String categoryId) => '/products?categoryId=$categoryId';

  /// Get product by ID
  static String productById(String id) => '/products/$id';

  // ========================================
  // User Endpoints
  // ========================================
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  /// Get user by ID
  static String userById(String id) => '/users/$id';
}
