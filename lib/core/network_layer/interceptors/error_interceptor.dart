import 'package:dio/dio.dart';
import '../../utils/logger.dart';
import '../network_exceptions.dart';

/// Error Interceptor
/// Handles and transforms Dio errors into custom exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);

    AppLogger.e('🔥 Network Exception: ${exception.message}', exception);

    // Transform DioException into custom NetworkException
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  /// Handle different types of errors
  NetworkException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException.timeout(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      case DioExceptionType.cancel:
        return const NetworkException.requestCancelled(
          message: 'Request was cancelled',
        );

      case DioExceptionType.connectionError:
        return const NetworkException.noInternetConnection(
          message: 'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException.serverError(
          message: 'SSL certificate verification failed',
          statusCode: null,
        );

      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') ?? false) {
          return const NetworkException.noInternetConnection(
            message: 'No internet connection',
          );
        }
        return NetworkException.unexpected(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  /// Handle HTTP status codes
  NetworkException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Extract error message from response
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        return NetworkException.badRequest(
          message: message ?? 'Bad request. Please check your input.',
          statusCode: statusCode,
        );

      case 401:
        return NetworkException.unauthorized(
          message: message ?? 'Unauthorized. Please login again.',
          statusCode: statusCode,
        );

      case 403:
        return NetworkException.forbidden(
          message: message ?? 'Access forbidden. You don\'t have permission.',
          statusCode: statusCode,
        );

      case 404:
        return NetworkException.notFound(
          message: message ?? 'Resource not found.',
          statusCode: statusCode,
        );

      case 409:
        return NetworkException.conflict(
          message: message ?? 'Conflict. Resource already exists.',
          statusCode: statusCode,
        );

      case 422:
        return NetworkException.validationError(
          message: message ?? 'Validation failed.',
          statusCode: statusCode,
          errors: data is Map<String, dynamic> ? data['errors'] : null,
        );

      case 500:
      case 501:
      case 502:
      case 503:
        return NetworkException.serverError(
          message: message ?? 'Server error. Please try again later.',
          statusCode: statusCode,
        );

      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return NetworkException.badRequest(
            message: message ?? 'Request failed with status $statusCode',
            statusCode: statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return NetworkException.serverError(
            message: message ?? 'Server error $statusCode',
            statusCode: statusCode,
          );
        } else {
          return NetworkException.unexpected(
            message: message ?? 'An unexpected error occurred',
          );
        }
    }
  }
}
