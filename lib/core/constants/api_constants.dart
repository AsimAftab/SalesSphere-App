/// API related constants
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  static const String baseUrlDev = 'https://dev-api.example.com';
  static const String baseUrlStaging = 'https://staging-api.example.com';
  static const String baseUrlProduction = 'https://api.example.com';

  // API Versions
  static const String apiVersion = '/api/v1';

  // Endpoints - Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // Endpoints - User
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/user/change-password';
  static const String deleteAccount = '/user/delete';

  // Endpoints - Products
  static const String products = '/products';
  static const String productDetail = '/products/{id}';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';

  // Endpoints - Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/{id}';
  static const String createOrder = '/orders/create';
  static const String cancelOrder = '/orders/{id}/cancel';

  // Endpoints - Sales
  static const String sales = '/sales';
  static const String salesReport = '/sales/report';
  static const String salesAnalytics = '/sales/analytics';

  // HTTP Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerApiKey = 'X-API-Key';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeUrlEncoded = 'application/x-www-form-urlencoded';

  // Error Codes
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
  static const int serviceUnavailable = 503;

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$apiVersion$endpoint';
  }

  // Helper method to replace path parameters
  static String replacePathParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}