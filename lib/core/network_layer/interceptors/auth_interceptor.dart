import 'package:dio/dio.dart';
import '../../utils/logger.dart';
import '../token_storage_service.dart';

/// Auth Interceptor
/// Automatically adds JWT token to request headers
class AuthInterceptor extends Interceptor {
  final TokenStorageService tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final token = await tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      // Add Authorization header
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.d('🔐 Token added to request: ${options.path}');
    } else {
      AppLogger.d('ℹ️ No token available for: ${options.path}');
    }

    // Continue with the request
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Check if response contains a new token
    final newToken = _extractTokenFromResponse(response);
    if (newToken != null) {
      tokenStorage.saveToken(newToken);
      AppLogger.i('🔄 New token saved from response');
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized (token expired or invalid)
    if (err.response?.statusCode == 401) {
      AppLogger.w('⚠️ Unauthorized (401): Token may be expired');

      // Attempt to refresh token (if using refresh token strategy)
      final refreshed = await _attemptTokenRefresh(err.requestOptions);

      if (refreshed) {
        // Retry the original request with new token
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          AppLogger.e('❌ Retry failed after token refresh', e);
        }
      } else {
        // Clear token and redirect to login
        await tokenStorage.clearAuthData();
        AppLogger.i('🔓 Auth data cleared due to 401');
      }
    }

    handler.next(err);
  }

  /// Extract token from response
  /// Adjust this based on your API response structure
  String? _extractTokenFromResponse(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check common token field names
        if (data.containsKey('token')) {
          return data['token'] as String?;
        }
        if (data.containsKey('access_token')) {
          return data['access_token'] as String?;
        }
        if (data.containsKey('accessToken')) {
          return data['accessToken'] as String?;
        }

        // Check nested data.token
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final nestedData = data['data'] as Map<String, dynamic>;
          if (nestedData.containsKey('token')) {
            return nestedData['token'] as String?;
          }
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('Error extracting token from response', e);
      return null;
    }
  }

  /// Attempt to refresh the token
  /// Implement your refresh token logic here
  Future<bool> _attemptTokenRefresh(RequestOptions requestOptions) async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.d('ℹ️ No refresh token available');
        return false;
      }

      AppLogger.d('🔄 Attempting to refresh token...');

      // TODO: Implement your refresh token API call here
      // Example:
      // final dio = Dio();
      // final response = await dio.post(
      //   '${requestOptions.baseUrl}/auth/refresh',
      //   data: {'refreshToken': refreshToken},
      // );
      //
      // if (response.statusCode == 200) {
      //   final newToken = response.data['token'];
      //   await tokenStorage.saveToken(newToken);
      //   return true;
      // }

      return false;
    } catch (e, stack) {
      AppLogger.e('❌ Token refresh failed', e, stack);
      return false;
    }
  }

  /// Retry the failed request with new token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await tokenStorage.getToken();

    // Update the authorization header with new token
    requestOptions.headers['Authorization'] = 'Bearer $token';

    AppLogger.i('🔄 Retrying request: ${requestOptions.path}');

    // Create a new Dio instance to avoid interceptor loops
    final dio = Dio();
    return await dio.fetch(requestOptions);
  }
}
