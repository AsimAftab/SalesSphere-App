/// API Endpoints
/// Centralized location for all API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints (Final)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgotpassword';
  static const String resetPassword = '/auth/resetpassword';
  static const String verifyEmail = '/auth/verify-email';
  static const String changePassword = '/auth/change-password';

  // User Endpoints
  static const String profile = '/users/me';
  static const String uploadProfileImage = '/users/me/profile-image';




  // Example: Products Endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String createProduct = '/products';
  static const String updateProduct = '/products';
  static const String deleteProduct = '/products';




  // Parties Endpoints (Final)
  static const String parties = '/parties';
  static String partyById(String id) => '/parties/$id';
  static const String createParty = '/parties';
  static String updateParty(String id) => '/parties/$id';
  static String deleteParty(String id) => '/parties/$id';

  //Prospects EndPoints (Final)
  static const String prospects = '/prospects';
  static String prospectsById(String id) => '/prospects/$id';
  static const String createProspects = '/prospects';
  static String updateProspects(String id) => '/prospects/$id';
  static String deleteProspects(String id) => '/parties/$id';
  static String transferToProspect(String id) => '/prospects/$id/transfer';

  // Sites Endpoints (Final)
  static const String sites = '/sites';
  static String siteById(String id) => '/sites/$id';
  static const String createSite = '/sites';
  static String updateSite(String id) => '/sites/$id';
  static String deleteSite(String id) => '/sites/$id';
  static String uploadSiteImage(String siteId) => '/sites/$siteId/images';
  static String deleteSiteImage(String siteId, int imageNumber) => '/sites/$siteId/images/$imageNumber';

  // File Upload
  static const String uploadImage = '/upload/image';
  static const String uploadFile = '/upload/file';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  // Home
  static const String home = '/home';

}
