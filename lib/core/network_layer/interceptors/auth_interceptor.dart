import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';

import '../../utils/logger.dart';
import '../token_storage_service.dart';

/// Auth Interceptor
/// Automatically adds JWT token to request headers
/// Handles automatic token refresh on 401 with concurrent request locking
class AuthInterceptor extends Interceptor {
  final TokenStorageService tokenStorage;
  final VoidCallback? onForceLogout;

  /// Endpoints that should NOT trigger token refresh on 401.
  /// A 401 on these means bad credentials, not an expired token.
  static const _authEndpoints = [
    '/auth/login',
    '/auth/refresh',
    '/auth/forgotpassword',
    '/auth/resetpassword',
  ];

  /// Mutex: only one refresh at a time. Concurrent 401s await this.
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this.tokenStorage, {this.onForceLogout});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get token from storage (now synchronous)
    final token = tokenStorage.getToken();

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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response contains a new token
    final newToken = _extractAndSaveTokens(response);
    if (newToken != null) {
      AppLogger.i('🔄 New token saved from response');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    AppLogger.w('⚠️ Unauthorized (401) on $path');

    // Don't attempt refresh for auth endpoints — 401 means bad credentials
    if (_isAuthEndpoint(path)) {
      AppLogger.w('⚠️ Auth endpoint returned 401. Not attempting refresh.');
      handler.next(err);
      return;
    }

    AppLogger.w('   Token may be expired. Attempting automatic refresh...');

    // Refresh with concurrency lock
    final refreshed = await _refreshTokenWithLock(err.requestOptions);

    if (refreshed) {
      AppLogger.i(
        '✅ Token refreshed successfully. Retrying original request...',
      );
      try {
        final response = await _retry(err.requestOptions);
        AppLogger.i('✅ Retry successful after token refresh');
        handler.resolve(response);
        return;
      } catch (e) {
        AppLogger.e('❌ Retry failed after token refresh', e);
      }
    } else {
      // Token refresh failed — force logout
      AppLogger.w('⚠️ Token refresh failed. Forcing logout...');
      await _handleAuthFailure();
    }

    handler.next(err);
  }

  /// Check if the request path is an auth endpoint
  bool _isAuthEndpoint(String path) {
    return _authEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Completer-based mutex: ensures only ONE refresh HTTP call at a time.
  /// Concurrent 401s wait for the in-progress refresh to complete.
  Future<bool> _refreshTokenWithLock(RequestOptions requestOptions) async {
    // Another refresh is already in progress — wait for it
    if (_refreshCompleter != null) {
      AppLogger.d('🔒 Refresh already in progress. Waiting...');
      return _refreshCompleter!.future;
    }

    // We are the first — create the lock and start refresh
    _refreshCompleter = Completer<bool>();

    try {
      final result = await _attemptTokenRefresh(requestOptions);
      _refreshCompleter!.complete(result);
      return result;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Attempt to refresh the token
  /// Makes API call to /api/v1/auth/refresh to get new tokens
  Future<bool> _attemptTokenRefresh(RequestOptions requestOptions) async {
    try {
      final refreshToken = tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.w(
          '⚠️ No refresh token available. Cannot refresh access token.',
        );
        return false;
      }

      AppLogger.i(
        '🔄 Attempting to refresh access token using refresh token...',
      );

      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Client-Type': 'mobile',
          },
        ),
      );

      // Make refresh token API call
      AppLogger.d('📡 Calling refresh token endpoint: /api/v1/auth/refresh');
      final response = await dio
          .post('/api/v1/auth/refresh', data: {'refreshToken': refreshToken})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw DioException(
                requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
                error: 'Token refresh timeout',
              );
            },
          );

      AppLogger.d('📡 Refresh token response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Extract new tokens from response
        String? newAccessToken;
        String? newRefreshToken;
        String? sessionExpiresAt;

        // Check root level first (for mobile clients with X-Client-Type header)
        newAccessToken = data['accessToken'] as String?;
        newRefreshToken = data['refreshToken'] as String?;

        // Check nested data object as fallback
        if (newAccessToken == null &&
            data.containsKey('data') &&
            data['data'] is Map<String, dynamic>) {
          final nestedData = data['data'] as Map<String, dynamic>;
          newAccessToken = nestedData['accessToken'] as String?;
          newRefreshToken = nestedData['refreshToken'] as String?;

          // Extract sessionExpiresAt from user object if present
          if (nestedData.containsKey('user') &&
              nestedData['user'] is Map<String, dynamic>) {
            final user = nestedData['user'] as Map<String, dynamic>;
            sessionExpiresAt = user['sessionExpiresAt'] as String?;
          }
        }

        // Save new tokens if found
        if (newAccessToken != null) {
          await tokenStorage.saveToken(newAccessToken);
          AppLogger.i('✅ New access token saved');

          if (newRefreshToken != null) {
            await tokenStorage.saveRefreshToken(newRefreshToken);
            AppLogger.i('✅ New refresh token saved');
          }

          if (sessionExpiresAt != null) {
            await tokenStorage.saveSessionExpiresAt(sessionExpiresAt);
            AppLogger.i('✅ Session updated, expires at: $sessionExpiresAt');
          }

          return true;
        } else {
          AppLogger.w('⚠️ No access token in refresh response');
          AppLogger.w('Response data: $data');
          return false;
        }
      } else {
        AppLogger.w(
          '⚠️ Token refresh failed with status: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        AppLogger.w(
          '⚠️ Refresh token is invalid or session expired (401 from backend)',
        );
        final errorData = e.response?.data;
        if (errorData is Map) {
          AppLogger.w('   Backend message: ${errorData['message']}');
        }
      } else {
        AppLogger.e('❌ Token refresh network error', e);
      }
      return false;
    } catch (e, stack) {
      AppLogger.e('❌ Token refresh failed', e, stack);
      return false;
    }
  }

  /// Clear auth data and notify Riverpod to force router redirect to login
  Future<void> _handleAuthFailure() async {
    await tokenStorage.clearAuthData();
    AppLogger.i('🔓 Auth data cleared. User needs to log in again.');
    onForceLogout?.call();
  }

  /// Extract tokens from response and save both access and refresh tokens
  String? _extractAndSaveTokens(Response response) {
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

  /// Retry the failed request with new token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = tokenStorage.getToken();

    // Update the authorization header with new token
    requestOptions.headers['Authorization'] = 'Bearer $token';

    AppLogger.i('🔄 Retrying request: ${requestOptions.path}');

    // Create a new Dio instance with proper base URL to avoid interceptor loops
    final dio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Type': 'mobile',
        },
      ),
    );

    return await dio.fetch(requestOptions);
  }
}
