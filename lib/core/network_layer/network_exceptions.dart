/// Custom Network Exceptions
/// Unified exception handling for all network errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  // Timeout Exception
  const NetworkException.timeout({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // No Internet Connection
  const NetworkException.noInternetConnection({
    required this.message,
  })  : statusCode = null,
        errors = null;

  // Bad Request (400)
  const NetworkException.badRequest({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Unauthorized (401)
  const NetworkException.unauthorized({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Forbidden (403)
  const NetworkException.forbidden({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Not Found (404)
  const NetworkException.notFound({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Conflict (409)
  const NetworkException.conflict({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Validation Error (422)
  const NetworkException.validationError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  // Server Error (500+)
  const NetworkException.serverError({
    required this.message,
    this.statusCode,
  }) : errors = null;

  // Request Cancelled
  const NetworkException.requestCancelled({
    required this.message,
  })  : statusCode = null,
        errors = null;

  // Unexpected Error
  const NetworkException.unexpected({
    required this.message,
  })  : statusCode = null,
        errors = null;

  @override
  String toString() {
    return 'NetworkException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
  }

  /// Get user-friendly error message
  String get userFriendlyMessage {
    if (statusCode == null) {
      return message;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Please login to continue.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This resource already exists.';
      case 422:
        return 'Please check your input and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server is temporarily unavailable. Please try again later.';
      default:
        return message;
    }
  }

  /// Check if error is due to authentication
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if error is client-side
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if error is server-side
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;
}
