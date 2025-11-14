import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/exceptions/offline_exception.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Connectivity Interceptor
/// Blocks all API requests when there's no internet connection
/// Throws typed OfflineException for easy handling
class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check connectivity before making request
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasConnection = !connectivityResults.contains(ConnectivityResult.none);

    if (!hasConnection) {
      AppLogger.w('🚫 Blocked API request - No internet connection: ${options.path}');

      // Reject with typed OfflineException
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const OfflineException(),
          message: 'No internet connection',
        ),
      );
    }

    // Connection available, proceed with request
    return handler.next(options);
  }
}
