import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'token_storage_service.dart';

/// Dio Client Provider
/// Provides a configured Dio instance with all interceptors
final dioClientProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  final dioClient = DioClient(tokenStorage);

  // Dispose dio when provider is disposed
  ref.onDispose(() {
    AppLogger.d('Disposing Dio client');
    dioClient.dio.close(force: true);
  });

  return dioClient.dio;
});

/// Dio Client Configuration
class DioClient {
  late final Dio dio;
  final TokenStorageService tokenStorage;

  DioClient(this.tokenStorage) {
    dio = Dio(_baseOptions);
    _setupInterceptors();
    AppLogger.i('✅ Dio Client initialized with base URL: $_baseUrl');
  }

  /// Base URL from environment
  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? '';
    if (url.isEmpty) {
      AppLogger.w('⚠️ API_BASE_URL not found in .env file');
      return 'https://api.example.com'; // Fallback URL
    }
    return url;
  }

  /// Base Options for Dio
  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes and handle them in interceptors
          return status != null && status < 500;
        },
      );

  /// Setup Interceptors
  void _setupInterceptors() {
    dio.interceptors.clear();

    // 1. Auth Interceptor (JWT Token)
    dio.interceptors.add(AuthInterceptor(tokenStorage));

    // 2. Logging Interceptor (Only in debug mode)
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }

    // 3. Error Interceptor (Global error handling)
    dio.interceptors.add(ErrorInterceptor());

    AppLogger.i('✅ Dio Interceptors configured: ${dio.interceptors.length}');
  }

  /// GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Download File
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload File
  Future<Response> upload(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }
}
