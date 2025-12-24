/// API Endpoints
/// Centralized location for all API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints (Final)
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String checkStatus = '/api/v1/auth/check-status';
  static const String forgotPassword = '/api/v1/auth/forgotpassword';
  static const String resetPassword = '/api/v1/auth/resetpassword';

  /// Get active tracking sessions for current user
  static const String activeTrackingSessions = '/api/v1/beat-plans/tracking/active';

  // User Endpoints
  static const String profile = '/api/v1/users/me';
  static const String uploadProfileImage = '/api/v1/users/me/profile-image';
  static const String changePassword = '/api/v1/users/me/password';

  // Catalog Endpoints (Final)
  static const String categories = '/api/v1/categories';
  static String categoryById(String id) => '/api/v1/categories/$id';

  static const String products = '/api/v1/products';
  static String productById(String id) => '/api/v1/products/$id';
  static const String createProduct = '/api/v1/products';
  static const String updateProduct = '/api/v1/products';
  static const String deleteProduct = '/api/v1/products';

  // Parties Endpoints (Final)
  static const String parties = '/api/v1/parties';
  static String partyById(String id) => '/api/v1/parties/$id';
  static const String createParty = '/api/v1/parties';
  static String updateParty(String id) => '/api/v1/parties/$id';
  static String deleteParty(String id) => '/api/v1/parties/$id';

  //Prospects EndPoints (Final)
  static const String prospects = '/api/v1/prospects';
  static String prospectsById(String id) => '/api/v1/prospects/$id';
  static const String createProspects = '/api/v1/prospects';
  static String updateProspects(String id) => '/api/v1/prospects/$id';
  static String deleteProspects(String id) => '/api/v1/prospects/$id';
  static String transferToProspect(String id) => '/api/v1/prospects/$id/transfer';

  // Sites Endpoints (Final)
  static const String sites = '/api/v1/sites';
  static String siteById(String id) => '/api/v1/sites/$id';
  static const String createSite = '/api/v1/sites';
  static String updateSite(String id) => '/api/v1/sites/$id';
  static String deleteSite(String id) => '/api/v1/sites/$id';
  static String uploadSiteImage(String siteId) => '/api/v1/sites/$siteId/images';
  static String deleteSiteImage(String siteId, int imageNumber) => '/api/v1/sites/$siteId/images/$imageNumber';

  // File Upload
  static const String uploadImage = '/api/v1/upload/image';
  static const String uploadFile = '/api/v1/upload/file';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String markNotificationRead = '/api/v1/notifications/read';

  // Home
  static const String home = '/api/v1/home';

  // Invoice Endpoints (Final)
  static const String invoices = '/api/v1/invoices';
  static String invoiceById(String id) => '/api/v1/invoices/$id';
  static const String createInvoice = '/api/v1/invoices';
  static String updateInvoice(String id) => '/api/v1/invoices/$id';
  static String deleteInvoice(String id) => '/api/v1/invoices/$id';

  // Estimate Endpoints
  static const String createEstimate = '/api/v1/invoices/estimates';
  static const String estimatesHistory = '/api/v1/invoices/estimates';
  static String estimateDetails(String id) => '/api/v1/invoices/estimates/$id';
  static String deleteEstimate(String id) => '/api/v1/invoices/estimates/$id';
  static String convertEstimateToInvoice(String id) => '/api/v1/invoices/estimates/$id/convert';

  // Attendance Endpoints (Final)
  static const String attendanceTodayStatus = '/api/v1/attendance/status/today';
  static const String attendanceCheckIn = '/api/v1/attendance/check-in';
  static const String attendanceCheckOut = '/api/v1/attendance/check-out';

  /// Get monthly attendance report
  /// Example: /api/v1/attendance/my-monthly-report?month=11&year=2025
  static String monthlyAttendanceReport({
    required int month,
    required int year,
  }) =>
      '/api/v1/attendance/my-monthly-report?month=$month&year=$year';

  /// Search attendance records with filters
  /// Example: /api/v1/attendance/search?status=P&month=11&year=2025&page=1&limit=20
  static String attendanceSearch({
    List<String>? status,
    int? month,
    int? year,
    String? startDate,
    String? endDate,
    double? latitude,
    double? longitude,
    double? radius,
    int page = 1,
    int limit = 20,
  }) {
    final queryParams = <String>[];

    if (status != null && status.isNotEmpty) {
      queryParams.add('status=${status.join(',')}');
    }
    if (month != null) queryParams.add('month=$month');
    if (year != null) queryParams.add('year=$year');
    if (startDate != null) queryParams.add('startDate=$startDate');
    if (endDate != null) queryParams.add('endDate=$endDate');
    if (latitude != null) queryParams.add('latitude=$latitude');
    if (longitude != null) queryParams.add('longitude=$longitude');
    if (radius != null) queryParams.add('radius=$radius');
    queryParams.add('page=$page');
    queryParams.add('limit=$limit');

    return '/api/v1/attendance/search?${queryParams.join('&')}';
  }

  // Beat Plan Endpoints
  /// Get beat plans assigned to current user (minimal data for cards)
  static const String myBeatPlans = '/api/v1/beat-plans/my-beatplans';

  /// Get beat plan details by ID (full data)
  static String beatPlanDetails(String id) => '/api/v1/beat-plans/$id/details';

  /// Start a beat plan (future - real-time tracking)
  static String startBeatPlan(String id) => '/api/v1/beat-plans/$id/start';

  /// Stop a beat plan (future - real-time tracking)
  static String stopBeatPlan(String id) => '/api/v1/beat-plans/$id/stop';

  /// Mark visit (POST with location data for geofencing)
  static String markVisit(String beatPlanId) =>
      '/api/v1/beat-plans/$beatPlanId/visit';

  /// Mark party visit as complete (deprecated - use markVisit instead)
  static String markVisitComplete(String beatPlanId, String visitId) =>
      '/api/v1/beat-plans/$beatPlanId/visits/$visitId/complete';

  /// Mark party visit as pending
  static String markVisitPending(String beatPlanId, String visitId) =>
      '/api/v1/beat-plans/$beatPlanId/visits/$visitId/pending';
}
