# SalesSphere - Project Overview

## Technology Stack

### Framework & Language
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language

### State Management
- **Riverpod 3.0**: Modern state management with code generation
- Uses `@riverpod` annotation-based code generation
- ViewModels extend generated classes (e.g., `LoginViewModel extends _$LoginViewModel`)
- Providers are auto-generated in `.g.dart` files

### Routing
- **GoRouter 16.3.0**: Declarative routing
- Centralized in `lib/core/router/route_handler.dart`
- Router is provided via `goRouterProvider`

### Data Models
- **Freezed 3.2.3**: Immutable data classes
- **json_serializable 6.11.1**: JSON serialization
- All models use `@freezed` annotation
- Provides `fromJson`/`toJson`, `copyWith`, equality

### UI/Styling
- **flutter_screenutil 5.9.3**: Responsive sizing (base design: 360x800)
- **FlexColorScheme 8.3.1**: Advanced Material 3 theming
- **flutter_svg**: SVG asset support

### Networking
- **Dio 5.9.0**: HTTP client
- Auto-configured with interceptors (Auth, Logging, Error)
- Base URL from `.env` file

### Other Key Dependencies
- **logger 2.6.2**: Centralized logging (AppLogger)
- **flutter_dotenv 6.0.0**: Environment variables
- **shared_preferences 2.5.3**: Local storage

---

## Project Structure

```
lib/
├── core/                   # Shared utilities, constants, theme, routing
│   ├── constants/          # App-wide constants
│   │   ├── app_assets.dart     # Asset paths (images, icons, fonts)
│   │   ├── app_colors.dart     # Color constants
│   │   ├── app_sizes.dart      # Spacing and sizing constants
│   │   ├── app_strings.dart    # String constants
│   │   ├── api_endpoints.dart  # API endpoint paths
│   │   └── storage_keys.dart   # SharedPreferences keys
│   ├── network_layer/      # Networking setup
│   │   ├── dio_client.dart         # Dio instance provider
│   │   ├── token_storage_service.dart  # JWT token management
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart     # Auto-adds auth headers
│   │   │   ├── logging_interceptor.dart  # Request/response logs
│   │   │   └── error_interceptor.dart    # Error handling
│   ├── router/             # GoRouter configuration
│   │   └── route_handler.dart  # All app routes
│   ├── theme/              # FlexColorScheme theming
│   │   └── theme.dart
│   ├── utils/              # Utilities
│   │   ├── logger.dart         # AppLogger class
│   │   └── field_validators.dart  # Form validators
│   └── providers/          # Global providers
│       ├── auth_init_provider.dart  # Auth initialization
│       └── user_controller.dart     # Global user state
├── features/               # Feature modules (feature-first structure)
│   ├── auth/
│   │   ├── models/         # Data models (Freezed classes)
│   │   │   ├── login.models.dart
│   │   │   ├── forgot_password.models.dart
│   │   │   ├── *.freezed.dart (generated)
│   │   │   └── *.g.dart (generated)
│   │   ├── views/          # UI screens
│   │   │   ├── login_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   └── vm/             # ViewModels (Riverpod AsyncNotifiers)
│   │       ├── login.vm.dart
│   │       ├── forgot_password.vm.dart
│   │       └── *.vm.g.dart (generated)
│   ├── home/
│   │   └── views/
│   ├── catalog/
│   │   ├── models/
│   │   ├── views/
│   │   └── vm/
│   ├── invoice/
│   ├── parties/
│   ├── profile/
│   └── settings/
└── widget/                 # Shared/reusable widgets
    ├── app_bottom_nav.dart
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── custom_date_picker.dart
    ├── main_shell.dart
    └── settings_tile.dart
```

---

## Architecture Patterns

### 1. Feature-First Organization
Each feature is self-contained with its own:
- **models**: Data structures
- **views**: UI screens
- **vm**: Business logic (ViewModels)

### 2. Riverpod ViewModels
```dart
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<LoginResponse?> build() async {
    // Initial state
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      // API call
      state = AsyncData(response);
    } catch (e) {
      state = AsyncError(e, stackTrace);
    }
  }
}
```

### 3. Freezed Models
```dart
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
```

### 4. GoRouter Navigation
```dart
// Navigate to a route
context.go('/forgot-password');

// Navigate with parameters
context.go('/edit_party_details_screen/\$partyId');

// Go back
context.go('/');
```

---

## Code Generation Workflow

### When to Run Code Generation
Run code generation when you create or modify:
- Riverpod providers (`@riverpod`)
- Freezed models (`@freezed`)
- JSON-serializable classes

### Commands
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Generated Files
- `*.g.dart`: Riverpod providers, JSON serialization
- `*.freezed.dart`: Freezed model classes

⚠️ **Important**: Generated files are gitignored but required for compilation

---

## Key Conventions

### File Naming
- **ViewModels**: `*.vm.dart` (e.g., `login.vm.dart`)
- **Models**: `*.models.dart` (e.g., `login.models.dart`)
- **Screens**: `*_screen.dart` (e.g., `login_screen.dart`)

### Imports
```dart
// Always use absolute imports
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_button.dart';
```

### Logging
```dart
// NEVER use print()
AppLogger.d('Debug message');
AppLogger.i('Info message');
AppLogger.w('Warning message');
AppLogger.e('Error message', error, stackTrace);
AppLogger.t('Trace message');
```

### Responsive Sizing
```dart
// Use .w for width, .h for height, .sp for font size, .r for radius
Container(
  width: 100.w,
  height: 50.h,
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 14.sp),
  ),
)
```

---

## App Configuration

### Portrait-Only Mode
App is locked to portrait orientation (configured in `main.dart`)

### Environment Variables
Create `.env` file in project root:
```
API_BASE_URL=https://your-api-url.com
```

### Base Design Dimensions
- Width: 360px
- Height: 800px
- All sizes are scaled using flutter_screenutil

---

## Network Layer

### Making API Calls
```dart
// In ViewModel
final dio = ref.read(dioClientProvider);
final response = await dio.post(ApiEndpoints.login, data: {...});
```

### Auth Token Management
```dart
final tokenStorage = ref.read(tokenStorageServiceProvider);

// Save token
await tokenStorage.saveToken(token);

// Get token
final token = await tokenStorage.getToken();

// Clear auth data
await tokenStorage.clearAuthData();
```

### Auto-configured Features
1. **AuthInterceptor**: Adds `Authorization: Bearer {token}` header
2. **LoggingInterceptor**: Logs requests/responses (debug mode only)
3. **ErrorInterceptor**: Transforms errors into `NetworkException`

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## Build Commands

```bash
# Android
flutter build apk           # Debug APK
flutter build appbundle     # Release bundle

# iOS
flutter build ios

# Web
flutter build web
```

---

## Static Analysis

```bash
# Run linter
flutter analyze

# Custom lints
# - riverpod_lint
# - freezed_lint
# - custom_lint
```

---

## Common Tasks

### Adding a New Feature
1. Create feature folder in `lib/features/my_feature/`
2. Create subfolders: `models/`, `views/`, `vm/`
3. Define models with `@freezed`
4. Create ViewModel with `@riverpod`
5. Build UI in views
6. Run code generation
7. Add route to `route_handler.dart`

### Adding API Endpoint
1. Add endpoint to `lib/core/constants/api_endpoints.dart`
2. Use in ViewModel via `dioClientProvider`

### Adding Constants
- **Colors**: `lib/core/constants/app_colors.dart`
- **Strings**: `lib/core/constants/app_strings.dart`
- **Sizes**: `lib/core/constants/app_sizes.dart`
- **Assets**: `lib/core/constants/app_assets.dart`

---

## Error Handling

### Global Error Handler
Configured in `main.dart` to log Flutter errors via AppLogger

### Network Errors
```dart
try {
  await dio.get('/endpoint');
} on DioException catch (e) {
  if (e.error is NetworkException) {
    final error = e.error as NetworkException;
    // Handle: error.message, error.isAuthError, error.userFriendlyMessage
  }
}
```

---

## Next Steps

For detailed information on:
- **Reusable Components**: See `REUSABLE_COMPONENTS.md`
- **Creating New Pages**: See `CREATING_NEW_PAGES.md`
- **Code Examples**: See `CODE_EXAMPLES.md`
- **Theming & Styling**: See `THEMING_AND_STYLING.md`
