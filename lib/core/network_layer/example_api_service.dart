import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../constants/api_endpoints.dart';
import 'dio_client.dart';
import 'network_exceptions.dart';

/// Example API Service Provider
final exampleApiServiceProvider = Provider<ExampleApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ExampleApiService(dio);
});

/// Example API Service
/// Shows how to use the Dio client for API calls
class ExampleApiService {
  final Dio _dio;

  ExampleApiService(this._dio);

  /// Example: Login API Call
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.i('🔐 Attempting login for: $email');

      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Login successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw NetworkException.unexpected(
          message: 'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Login failed', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(message: e.message ?? 'Login failed');
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during login', e, stack);
      throw const NetworkException.unexpected(message: 'An unexpected error occurred');
    }
  }

  /// Example: Register API Call
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.i('📝 Attempting registration for: $email');

      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Registration successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw NetworkException.unexpected(
          message: 'Registration failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Registration failed', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Registration failed',
      );
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during registration', e, stack);
      throw const NetworkException.unexpected(message: 'An unexpected error occurred');
    }
  }

  /// Example: Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      AppLogger.i('👤 Fetching user profile');

      final response = await _dio.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        AppLogger.i('✅ Profile fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw NetworkException.unexpected(
          message: 'Failed to fetch profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch profile', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Failed to fetch profile',
      );
    }
  }

  /// Example: Update Profile
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.i('✏️ Updating user profile');

      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Profile updated successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw NetworkException.unexpected(
          message: 'Failed to update profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to update profile', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Failed to update profile',
      );
    }
  }

  /// Example: Get List with Query Parameters
  Future<List<dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      AppLogger.i('📦 Fetching products (page: $page, limit: $limit)');

      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Products fetched successfully');

        // Handle different response structures
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          // If API returns {data: [...], meta: {...}}
          return (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
        } else {
          throw const NetworkException.unexpected(
            message: 'Unexpected response format',
          );
        }
      } else {
        throw NetworkException.unexpected(
          message: 'Failed to fetch products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch products', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Failed to fetch products',
      );
    }
  }

  /// Example: Upload File
  Future<Map<String, dynamic>> uploadImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      AppLogger.i('📤 Uploading image: $fileName');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          AppLogger.d('Upload progress: $progress%');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Image uploaded successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw NetworkException.unexpected(
          message: 'Upload failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Image upload failed', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Upload failed',
      );
    }
  }

  /// Example: Logout
  Future<void> logout() async {
    try {
      AppLogger.i('🚪 Logging out');

      final response = await _dio.post(ApiEndpoints.logout);

      if (response.statusCode == 200) {
        AppLogger.i('✅ Logout successful');
      } else {
        throw NetworkException.unexpected(
          message: 'Logout failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Logout failed', e);
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException.unexpected(
        message: e.message ?? 'Logout failed',
      );
    }
  }
}
