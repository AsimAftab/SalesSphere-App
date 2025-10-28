# Network Layer Documentation

Comprehensive network layer built with Dio, Riverpod 3.0, and proper JWT token handling.

## 📁 Structure

```
network_layer/
├── dio_client.dart              # Main Dio configuration
├── token_storage_service.dart   # JWT token storage
├── api_endpoints.dart           # API endpoint constants
├── network_exceptions.dart      # Custom exceptions
├── example_api_service.dart     # Example usage
└── interceptors/
    ├── auth_interceptor.dart    # JWT token interceptor
    ├── logging_interceptor.dart # Request/response logging
    └── error_interceptor.dart   # Error handling
```

## 🚀 Features

- ✅ **Automatic JWT Token Injection** - Adds Bearer token to all requests
- ✅ **Request/Response Logging** - Beautiful console logs in debug mode
- ✅ **Error Handling** - Transforms errors into custom exceptions
- ✅ **Token Refresh** - Automatic token refresh on 401 errors
- ✅ **Base URL from .env** - Configurable environment
- ✅ **Timeout Handling** - 30-second timeout
- ✅ **File Upload Support** - With progress tracking
- ✅ **Riverpod 3.0 Compatible** - Uses @riverpod annotation

## 📖 Setup

### 1. Add Base URL to .env file

```env
API_BASE_URL=https://your-api-url.com/api
API_KEY=your_api_key_here  # Optional
```

### 2. Initialize in main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize token storage
  final tokenStorage = TokenStorageService();
  await tokenStorage.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 💻 Usage

### Basic API Call

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    final dio = ref.read(dioClientProvider);

    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final tokenStorage = ref.read(tokenStorageServiceProvider);
        await tokenStorage.saveToken(token);

        // Success!
      }
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        final networkError = e.error as NetworkException;
        // Handle error: networkError.message
      }
    }
  }
}
```

### Using API Service

```dart
@riverpod
class ProductsViewModel extends _$ProductsViewModel {
  @override
  Future<List<Product>> build() async {
    return await _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final apiService = ref.read(exampleApiServiceProvider);

    try {
      final data = await apiService.getProducts(
        page: 1,
        limit: 20,
        search: 'laptop',
      );

      return data.map((json) => Product.fromJson(json)).toList();
    } on NetworkException catch (e) {
      AppLogger.e('Failed to load products', e);
      throw e;
    }
  }
}
```

### File Upload with Progress

```dart
Future<void> uploadProfileImage(String filePath) async {
  final apiService = ref.read(exampleApiServiceProvider);

  try {
    final result = await apiService.uploadImage(
      filePath: filePath,
      fileName: 'profile.jpg',
    );

    AppLogger.i('Upload successful: ${result['url']}');
  } on NetworkException catch (e) {
    AppLogger.e('Upload failed', e);
  }
}
```

### Manual Token Management

```dart
// Save token
final tokenStorage = ref.read(tokenStorageServiceProvider);
await tokenStorage.saveToken('your_jwt_token');

// Get token
final token = await tokenStorage.getToken();

// Delete token
await tokenStorage.deleteToken();

// Clear all auth data
await tokenStorage.clearAuthData();
```

## 🔐 JWT Token Flow

1. **Login** → Receive token → Save to SharedPreferences
2. **Subsequent Requests** → Auth interceptor adds `Authorization: Bearer {token}`
3. **401 Error** → Attempt token refresh → Retry original request
4. **Refresh Failed** → Clear token → Redirect to login

## 📊 Request Logging

In debug mode, all requests/responses are logged beautifully:

```
╔══════════════════════════════════════════════════════════════
║ 📤 REQUEST
╠══════════════════════════════════════════════════════════════
║ Method: POST
║ URL: https://api.example.com/auth/login
║ Headers:
║   Content-Type: application/json
║   Authorization: Bearer ***
║ Body:
║   {
║     "email": "user@example.com",
║     "password": "***"
║   }
╚══════════════════════════════════════════════════════════════
```

## 🛡️ Error Handling

### Custom Network Exceptions

```dart
try {
  await apiService.getProfile();
} on NetworkException catch (e) {
  if (e.isAuthError) {
    // Redirect to login
  } else if (e.isServerError) {
    // Show server error message
  } else {
    // Show generic error
  }

  // User-friendly message
  showSnackbar(e.userFriendlyMessage);
}
```

### Exception Types

- `NetworkException.timeout` - Request timeout
- `NetworkException.noInternetConnection` - No network
- `NetworkException.badRequest` - 400 errors
- `NetworkException.unauthorized` - 401 errors
- `NetworkException.forbidden` - 403 errors
- `NetworkException.notFound` - 404 errors
- `NetworkException.serverError` - 500+ errors
- `NetworkException.validationError` - 422 errors with field validation

## 🎯 API Endpoints

Centralized endpoint management:

```dart
class ApiEndpoints {
  static const String login = '/auth/login';
  static const String profile = '/user/profile';
  static String userById(String id) => '/users/$id';
}

// Usage
await dio.get(ApiEndpoints.profile);
await dio.get(ApiEndpoints.userById('123'));
```

## 🔧 Customization

### Add Custom Interceptor

```dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Custom logic
    handler.next(options);
  }
}

// Add to DioClient
dio.interceptors.add(CustomInterceptor());
```

### Modify Timeout

Edit `dio_client.dart`:

```dart
BaseOptions get _baseOptions => BaseOptions(
  baseUrl: _baseUrl,
  connectTimeout: const Duration(seconds: 60), // Changed
  receiveTimeout: const Duration(seconds: 60), // Changed
  // ...
);
```

## 📝 Best Practices

1. **Always use try-catch** when making API calls
2. **Handle NetworkException** for proper error messages
3. **Log important events** using AppLogger
4. **Use API constants** from ApiEndpoints
5. **Create dedicated service classes** for each feature
6. **Don't store tokens in plain text** (already handled by SharedPreferences encryption)
7. **Clear tokens on logout**

## 🚦 Migration Guide

To use this network layer in existing code:

1. Replace manual Dio instances with `ref.read(dioClientProvider)`
2. Replace try-catch DioException with NetworkException
3. Use TokenStorageService for token management
4. Update API endpoints to use ApiEndpoints constants

## 📞 Support

For issues or questions, check:
- Dio documentation: https://pub.dev/packages/dio
- Riverpod documentation: https://riverpod.dev
