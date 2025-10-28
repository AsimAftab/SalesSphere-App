# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SalesSphere is a Flutter application built with a modern architecture using Riverpod 3.0 for state management, GoRouter for navigation, and code generation tools (Freezed, json_serializable, riverpod_generator).

## Development Commands

### Code Generation
Run code generation for Riverpod providers, Freezed models, and JSON serialization:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode for continuous code generation during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
flutter run
```

### Testing
```bash
flutter test
```

### Linting & Analysis
Static analysis with custom_lint (includes riverpod_lint and freezed_lint):
```bash
flutter analyze
```

### Build Commands
```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web
```

## Architecture

### State Management: Riverpod 3.0
- Uses the new `@riverpod` annotation-based code generation
- ViewModels extend `_$ViewModelName` generated classes (e.g., `LoginViewModel extends _$LoginViewModel`)
- Providers are automatically generated in `.g.dart` files
- Custom `LoggerProviderObserver` in main.dart tracks provider lifecycle in debug mode
- AsyncNotifier pattern for async operations with built-in loading/error states

### Routing: GoRouter
- Centralized routing in `lib/core/router/route_handler.dart`
- Router is provided via `goRouterProvider` and watched by the App widget
- Routes use declarative GoRoute configuration

### Models: Freezed + JSON Serializable
- All data models use `@freezed` annotation for immutability and code generation
- Requires `part 'model_name.freezed.dart'` and `part 'model_name.g.dart'`
- Provides `fromJson`/`toJson`, `copyWith`, equality, and union types

### Feature-First Structure
```
lib/
├── core/               # Shared utilities, constants, theme, routing
│   ├── constants/      # App-wide constants (colors, sizes, strings, API, storage keys)
│   ├── router/         # GoRouter configuration
│   ├── theme/          # FlexColorScheme-based theming
│   ├── utils/          # Logger, validators, utilities
│   └── network_layer/  # Networking setup (currently empty, expects Dio setup)
├── features/           # Feature modules
│   └── auth/
│       ├── models/     # Data models (Freezed classes)
│       ├── views/      # UI screens
│       └── vm/         # ViewModels (Riverpod AsyncNotifiers)
└── widget/             # Shared/reusable widgets
```

### Theme & Styling
- Uses FlexColorScheme for advanced Material 3 theming
- Theme configured in `lib/core/theme/theme.dart`
- Screen-responsive sizing via flutter_screenutil (base design: 360x800)
- Custom colors/sizes defined in `lib/core/constants/`
- Text scaling clamped between 0.8-1.3x

### Logging
- Centralized `AppLogger` class in `lib/core/utils/logger.dart`
- Methods: `AppLogger.d()`, `AppLogger.i()`, `AppLogger.w()`, `AppLogger.e()`, `AppLogger.t()`
- Configured with PrettyPrinter for readable console output
- Never use `print()` statements (enforced by linter)

## Key Dependencies

- **flutter_riverpod**: ^3.0.3 (state management)
- **riverpod_annotation**: ^3.0.3 + riverpod_generator (code generation)
- **go_router**: ^16.3.0 (declarative routing)
- **freezed**: ^3.2.3 + freezed_annotation (immutable models)
- **json_serializable**: ^6.11.1 (JSON serialization)
- **dio**: ^5.9.0 (HTTP client - not yet configured)
- **flutter_screenutil**: ^5.9.3 (responsive sizing)
- **flex_color_scheme**: ^8.3.1 (advanced theming)
- **logger**: ^2.6.2 (logging)
- **flutter_dotenv**: ^6.0.0 (environment variables)
- **shared_preferences**: ^2.5.3 (local storage)

## Code Generation Workflow

When creating new Riverpod providers, Freezed models, or JSON-serializable classes:

1. Add the appropriate annotations (`@riverpod`, `@freezed`, `@JsonSerializable`)
2. Add required `part` statements for generated files
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Generated files (`.g.dart`, `.freezed.dart`) are gitignored but required for compilation

## Network Layer

### Dio Client Setup
- **Base URL**: Configured in `.env` file (`API_BASE_URL`)
- **Provider**: Use `ref.read(dioClientProvider)` to get Dio instance
- **Token Storage**: `TokenStorageService` handles JWT token storage in SharedPreferences
- **Auto-init**: Token storage and .env loaded in main.dart

### Interceptors (Auto-configured)
1. **AuthInterceptor**: Automatically adds `Authorization: Bearer {token}` header
2. **LoggingInterceptor**: Beautiful request/response logs (debug mode only)
3. **ErrorInterceptor**: Transforms errors into custom `NetworkException`

### Making API Calls
```dart
// In ViewModel
final dio = ref.read(dioClientProvider);
final response = await dio.post('/auth/login', data: {...});

// Save token after login
final tokenStorage = ref.read(tokenStorageServiceProvider);
await tokenStorage.saveToken(response.data['token']);
```

### Error Handling
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

### API Endpoints
- Centralized in `lib/core/network_layer/api_endpoints.dart`
- Example: `ApiEndpoints.login`, `ApiEndpoints.userById('123')`

## Conventions

- **ViewModels**: Named with `.vm.dart` suffix, use AsyncNotifier pattern
- **Models**: Use Freezed for all data classes requiring immutability/serialization
- **Validation**: Field validators in `lib/core/utils/field_validators.dart`
- **Constants**: Organized by type (colors, sizes, strings, API, storage) in `lib/core/constants/`
- **Portrait-only**: App locked to portrait orientation (configured in main.dart)
- **Error Handling**: Global Flutter error handler logs to AppLogger in main.dart
- **Network Calls**: Always use `dioClientProvider`, handle `NetworkException`
