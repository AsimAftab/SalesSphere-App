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

  /// Extract tokens from response and save both access and refresh tokens
  /// Adjust this based on your API response structure
  String? _extractTokenFromResponse(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Extract accessToken
        String? accessToken;
        if (data.containsKey('accessToken')) {
          accessToken = data['accessToken'] as String?;
        }

        // Extract refreshToken
        String? refreshToken;
        if (data.containsKey('refreshToken')) {
          refreshToken = data['refreshToken'] as String?;
        }

        // Save both tokens if found
        if (accessToken != null) {
          tokenStorage.saveToken(accessToken);
          if (refreshToken != null) {
            tokenStorage.saveRefreshToken(refreshToken);
          }
          return accessToken;
        }

        // Check nested data for tokens
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final nestedData = data['data'] as Map<String, dynamic>;

          if (nestedData.containsKey('accessToken')) {
            accessToken = nestedData['accessToken'] as String?;
          }
          if (nestedData.containsKey('refreshToken')) {
            refreshToken = nestedData['refreshToken'] as String?;
          }

          if (accessToken != null) {
            tokenStorage.saveToken(accessToken);
            if (refreshToken != null) {
              tokenStorage.saveRefreshToken(refreshToken);
            }
            return accessToken;
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
  /// Makes API call to /api/v1/auth/refresh to get new tokens
  Future<bool> _attemptTokenRefresh(RequestOptions requestOptions) async {
    try {
      // Check if session has expired before attempting refresh
      final isExpired = await tokenStorage.isSessionExpired();
      if (isExpired) {
        AppLogger.w('⚠️ Session has expired. Cannot refresh token. Forcing logout...');
        await tokenStorage.clearAuthData();
        return false;
      }

      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.d('ℹ️ No refresh token available');
        return false;
      }

      AppLogger.d('🔄 Attempting to refresh token...');

      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(
        baseUrl: requestOptions.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Type': 'mobile',
        },
      ));

      // Make refresh token API call
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Extract new tokens and user from response
        String? newAccessToken;
        String? newRefreshToken;
        String? sessionExpiresAt;

        // Check if tokens are in root or nested in data
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final nestedData = data['data'] as Map<String, dynamic>;
          newAccessToken = nestedData['accessToken'] as String?;
          newRefreshToken = nestedData['refreshToken'] as String?;

          // Extract sessionExpiresAt from user object if present
          if (nestedData.containsKey('user') && nestedData['user'] is Map<String, dynamic>) {
            final user = nestedData['user'] as Map<String, dynamic>;
            sessionExpiresAt = user['sessionExpiresAt'] as String?;
          }
        } else {
          newAccessToken = data['accessToken'] as String?;
          newRefreshToken = data['refreshToken'] as String?;
        }

        // Save new tokens if found
        if (newAccessToken != null) {
          await tokenStorage.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await tokenStorage.saveRefreshToken(newRefreshToken);
          }
          // Save session expiry date if present
          if (sessionExpiresAt != null) {
            await tokenStorage.saveSessionExpiresAt(sessionExpiresAt);
            AppLogger.i('✅ Session updated, expires at: $sessionExpiresAt');
          }
          AppLogger.i('✅ Token refreshed successfully');
          return true;
        } else {
          AppLogger.w('⚠️ No access token in refresh response');
          return false;
        }
      } else {
        AppLogger.w('⚠️ Token refresh failed with status: ${response.statusCode}');
        return false;
      }
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
