/// API Endpoints
/// Centralized location for all API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints (Final)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String changePassword = '/auth/change-password';

  // User Endpoints
  static const String profile = '/users/me';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/delete';

  // Example: Sales Endpoints
  static const String sales = '/sales';
  static String saleById(String id) => '/sales/$id';
  static const String createSale = '/sales';
  static const String updateSale = '/sales';
  static const String deleteSale = '/sales';

  // Example: Products Endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String createProduct = '/products';
  static const String updateProduct = '/products';
  static const String deleteProduct = '/products';

  // Example: Customers Endpoints
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
  static const String createCustomer = '/customers';
  static const String updateCustomer = '/customers';
  static const String deleteCustomer = '/customers';

  // Parties Endpoints (Final)
  static const String parties = '/parties';
  static String partyById(String id) => '/parties/$id';
  static const String createParty = '/parties';
  static String updateParty(String id) => '/parties/$id';
  static String deleteParty(String id) => '/parties/$id';

  // File Upload
  static const String uploadImage = '/upload/image';
  static const String uploadFile = '/upload/file';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  // Analytics
  static const String home = '/home';
  static const String salesReport = '/analytics/sales-report';
  static const String revenueReport = '/analytics/revenue-report';
}
