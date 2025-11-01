# SalesSphere - Architecture Overview

**Created:** 2025-11-01
**Project:** SalesSphere Flutter Application
**Purpose:** Complete architectural documentation and technical overview

---

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Design Patterns](#design-patterns)
5. [State Management](#state-management)
6. [Data Flow](#data-flow)
7. [Navigation](#navigation)
8. [Networking](#networking)
9. [Code Generation](#code-generation)
10. [Best Practices](#best-practices)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                            │
│  (Widgets, Screens, Components)                            │
│                                                              │
│  - ConsumerWidget/ConsumerStatefulWidget                   │
│  - Flutter Material Design                                  │
│  - Responsive layouts (flutter_screenutil)                 │
└──────────────────┬──────────────────────────────────────────┘
                   │ ref.watch() / ref.read()
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                        │
│  (ViewModels, Business Logic)                              │
│                                                              │
│  - Riverpod Providers (@riverpod annotation)               │
│  - AsyncNotifier pattern                                    │
│  - State management and validation                          │
└──────────────────┬──────────────────────────────────────────┘
                   │ API calls / Data operations
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  (Models, Repositories, Services)                          │
│                                                              │
│  - Freezed models (immutable)                               │
│  - JSON serialization                                       │
│  - Dio HTTP client                                          │
│  - SharedPreferences (local storage)                        │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend/Storage                          │
│                                                              │
│  - REST API (Node.js + MongoDB)                            │
│  - Local Storage (SharedPreferences)                        │
│  - File System (images, cache)                             │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture Layers

```
┌───────────────────────────────────────────────────────────┐
│                    Presentation Layer                      │
│                                                            │
│  Purpose: UI and user interaction                         │
│  Contains:                                                 │
│    - Screens (views/)                                     │
│    - Widgets (widget/)                                    │
│    - ViewModels (vm/)                                     │
│                                                            │
│  Dependencies: ← Presentation Layer can depend on Domain  │
└────────────────────┬──────────────────────────────────────┘
                     │
                     ▼
┌───────────────────────────────────────────────────────────┐
│                      Domain Layer                          │
│                                                            │
│  Purpose: Business logic and rules                        │
│  Contains:                                                 │
│    - Models (models/)                                     │
│    - Validators (utils/field_validators.dart)            │
│    - Constants (constants/)                               │
│                                                            │
│  Dependencies: ← Independent (no dependencies)            │
└────────────────────┬──────────────────────────────────────┘
                     │
                     ▼
┌───────────────────────────────────────────────────────────┐
│                       Data Layer                           │
│                                                            │
│  Purpose: Data access and storage                         │
│  Contains:                                                 │
│    - API services (network_layer/)                        │
│    - Local storage (shared_preferences)                   │
│    - Dio client configuration                             │
│                                                            │
│  Dependencies: ← Can depend on Domain                     │
└───────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Core Framework
- **Flutter 3.x**: UI framework
- **Dart 3.x**: Programming language

### State Management
- **flutter_riverpod 3.0.3**: State management
- **riverpod_annotation 3.0.3**: Code generation for providers
- **riverpod_generator**: Build-time code generation

### Data Modeling
- **freezed 3.2.3**: Immutable models and unions
- **freezed_annotation**: Annotations for code generation
- **json_annotation**: JSON serialization annotations
- **json_serializable 6.11.1**: JSON serialization code generation

### Networking
- **dio 5.9.0**: HTTP client
- **retrofit** (planned): Type-safe API client

### Navigation
- **go_router 16.3.0**: Declarative routing

### UI & Styling
- **flutter_screenutil 5.9.3**: Responsive sizing
- **flex_color_scheme 8.3.1**: Advanced theming (Material 3)

### Storage
- **shared_preferences 2.5.3**: Key-value local storage

### Utilities
- **logger 2.6.2**: Logging
- **flutter_dotenv 6.0.0**: Environment variables
- **image_picker 1.2.0**: Image selection

### Code Quality
- **custom_lint**: Custom lint rules
- **riverpod_lint**: Riverpod-specific lints
- **freezed_lint**: Freezed-specific lints

---

## Project Structure

### Feature-First Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # App configuration
│
├── core/                              # Shared core functionality
│   ├── constants/                     # App-wide constants
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   ├── api_endpoints.dart
│   │   └── storage_keys.dart
│   │
│   ├── network_layer/                 # Networking setup
│   │   ├── dio_client.dart           # Dio configuration
│   │   ├── token_storage_service.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── error_interceptor.dart
│   │   └── network_exception.dart
│   │
│   ├── providers/                     # Global providers
│   │   ├── auth_init_provider.dart
│   │   └── user_controller.dart
│   │
│   ├── router/                        # Navigation
│   │   └── route_handler.dart        # GoRouter configuration
│   │
│   ├── theme/                         # App theming
│   │   └── theme.dart                # FlexColorScheme config
│   │
│   └── utils/                         # Utility functions
│       ├── logger.dart               # AppLogger wrapper
│       ├── field_validators.dart     # Form validators
│       └── date_formatter.dart
│
├── features/                          # Feature modules
│   │
│   ├── auth/                          # Authentication
│   │   ├── models/
│   │   │   └── login.models.dart
│   │   ├── views/
│   │   │   └── login_screen.dart
│   │   └── vm/
│   │       └── login.vm.dart
│   │
│   ├── profile/                       # User Profile
│   │   ├── models/
│   │   │   └── profile.model.dart
│   │   ├── view/
│   │   │   └── profile_screen.dart
│   │   └── vm/
│   │       └── profile.vm.dart
│   │
│   ├── parties/                       # Parties List
│   ├── catalog/                       # Product Catalog
│   ├── home/                          # Home Dashboard
│   └── settings/                      # Settings
│
└── widget/                            # Reusable widgets
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── app_bottom_nav.dart
    └── settings_tile.dart
```

### Why Feature-First?

**Benefits:**
- ✅ **Scalability**: Easy to add new features
- ✅ **Maintainability**: Related code stays together
- ✅ **Team collaboration**: Developers work on separate features
- ✅ **Code organization**: Clear boundaries between features
- ✅ **Testing**: Easy to test features in isolation

**Alternative Considered:** Layer-first (models/, views/, viewmodels/)
**Rejected Because:** Hard to find related files as app grows

---

## Design Patterns

### 1. MVVM (Model-View-ViewModel)

```
View (Widget)
    ↓ watches
ViewModel (Provider)
    ↓ manages
Model (Freezed class)
```

**Example: Profile Page**

```dart
// Model (models/profile.model.dart)
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String fullName,
    // ...
  }) = _Profile;
}

// ViewModel (vm/profile.vm.dart)
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile?> build() async {
    return await fetchProfile();
  }

  Future<bool> updateProfile(UpdateProfileRequest request) {
    // Business logic
  }
}

// View (view/profile_screen.dart)
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return profileState.when(
      data: (profile) => _buildContent(profile),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(e),
    );
  }
}
```

### 2. Repository Pattern (Planned)

```dart
// Future implementation for data layer
abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> updateProfile(Profile profile);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  @override
  Future<Profile> getProfile() async {
    final response = await _dio.get('/profile');
    return Profile.fromJson(response.data);
  }
}
```

### 3. Dependency Injection (Riverpod)

```dart
// Provider definition
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  // Auto-injected dependencies
}

// Usage in widgets
final profile = ref.watch(profileViewModelProvider);
ref.read(profileViewModelProvider.notifier).updateProfile(...);
```

### 4. Factory Pattern (Freezed)

```dart
// Multiple constructors via Freezed
@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(User user) = _Success;
  const factory LoginState.error(String message) = _Error;
}
```

---

## State Management

### Riverpod Provider Types

#### 1. Provider (Simple values)
```dart
@riverpod
String appVersion(AppVersionRef ref) {
  return '1.0.0';
}
```

#### 2. StateNotifier (Mutable state)
```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

#### 3. AsyncNotifier (Async operations)
```dart
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile?> build() async {
    return await fetchProfile();
  }
}
```

#### 4. FutureProvider (One-time async)
```dart
@riverpod
Future<String> fetchData(FetchDataRef ref) async {
  return await api.getData();
}
```

### State Lifecycle

```
Provider Created
    ↓
build() called → Returns initial state
    ↓
Widget watches provider
    ↓
State changes (via methods)
    ↓
Widgets rebuild automatically
    ↓
Provider disposed when no listeners
```

---

## Data Flow

### Request Flow (Profile Update Example)

```
1. User Action
   ProfileScreen → User clicks "Save"
       ↓
2. UI Layer
   _handleSave() → Validates form
       ↓
3. Create Request Model
   UpdateProfileRequest(...) → Freezed model
       ↓
4. Call ViewModel
   ref.read(profileViewModel.notifier).updateProfile(request)
       ↓
5. ViewModel Processing
   ProfileViewModel.updateProfile()
   ├─ Set state to loading
   ├─ Call API via Dio
   ├─ Parse response
   └─ Update state (success/error)
       ↓
6. State Update
   state = AsyncData(updatedProfile)
       ↓
7. UI Reacts
   ref.watch() detects change → Widget rebuilds
       ↓
8. User Feedback
   SnackBar shows success message
```

### Data Persistence Flow

```
User uploads profile image
    ↓
ImagePicker returns local file path
    ↓
Save to SharedPreferences
    prefs.setString('profile_image_path', localPath)
    ↓
Update Profile state
    profile.copyWith(profileImageUrl: localPath)
    ↓
UI displays image
    Image.file(File(localPath))
    ↓
On app restart
    ↓
Load from SharedPreferences
    final savedPath = prefs.getString('profile_image_path')
    ↓
Populate Profile model
    Profile(profileImageUrl: savedPath)
    ↓
UI displays persisted image
```

---

## Navigation

### GoRouter Configuration

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
```

### Navigation Methods

```dart
// Push new route
context.push('/profile');

// Replace current route
context.replace('/login');

// Go to route (clears stack)
context.go('/home');

// Pop current route
context.pop();

// Pop with result
context.pop(result);
```

---

## Networking

### Dio Client Setup

```dart
@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? '',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Interceptors
  dio.interceptors.add(AuthInterceptor());        // Add token
  dio.interceptors.add(LoggingInterceptor());     // Log requests
  dio.interceptors.add(ErrorInterceptor());       // Transform errors

  return dio;
}
```

### API Call Pattern

```dart
Future<Profile> fetchProfile() async {
  state = const AsyncLoading();

  try {
    final dio = ref.read(dioClientProvider);
    final response = await dio.get('/api/profile');

    final profile = Profile.fromJson(response.data['data']);
    state = AsyncData(profile);
    return profile;
  } on DioException catch (e) {
    if (e.error is NetworkException) {
      final error = e.error as NetworkException;
      state = AsyncError(error, StackTrace.current);
      throw error;
    }
    rethrow;
  }
}
```

### Interceptors

#### Auth Interceptor
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorageService().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

#### Logging Interceptor
```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.i('🌐 ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.i('✅ ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }
}
```

---

## Code Generation

### Build Runner Commands

```bash
# Generate code once
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

### Generated Files

```
For each Freezed model:
  ✓ .freezed.dart - Immutable class implementation
  ✓ .g.dart       - JSON serialization

For each Riverpod provider:
  ✓ .g.dart       - Provider implementation
```

### What Gets Generated

```dart
// Source file: profile.model.dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String name,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

// Generated: profile.model.freezed.dart
// - _$Profile class
// - copyWith method
// - == operator
// - hashCode

// Generated: profile.model.g.dart
// - _$ProfileFromJson function
// - toJson method
```

---

## Best Practices

### 1. State Management

✅ **DO:**
```dart
// Use AsyncNotifier for async operations
@riverpod
class DataViewModel extends _$DataViewModel {
  @override
  Future<Data?> build() async {
    return await fetchData();
  }
}

// Watch in UI
final data = ref.watch(dataViewModelProvider);
```

❌ **DON'T:**
```dart
// Don't manage async state manually
class DataViewModel {
  bool isLoading = false;
  Data? data;
  String? error;

  Future<void> fetch() async {
    isLoading = true;
    // ...
  }
}
```

### 2. Models

✅ **DO:**
```dart
// Use Freezed for immutable models
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;
}
```

❌ **DON'T:**
```dart
// Don't use mutable classes
class User {
  String id;
  String name;

  User(this.id, this.name);
}
```

### 3. Validation

✅ **DO:**
```dart
// Use validators from FieldValidators
validator: (value) => FieldValidators.validateEmail(value)
```

❌ **DON'T:**
```dart
// Don't write inline validation logic
validator: (value) {
  if (value == null) return 'Required';
  if (!value.contains('@')) return 'Invalid email';
  // Duplicated across codebase
}
```

### 4. Error Handling

✅ **DO:**
```dart
// Handle errors gracefully
try {
  await api.call();
} on DioException catch (e) {
  if (e.error is NetworkException) {
    final error = e.error as NetworkException;
    // Show user-friendly message
    showError(error.userFriendlyMessage);
  }
}
```

❌ **DON'T:**
```dart
// Don't ignore errors
try {
  await api.call();
} catch (e) {
  // Silent failure
}
```

### 5. Navigation

✅ **DO:**
```dart
// Use context extension methods
context.push('/profile');
context.pop();
```

❌ **DON'T:**
```dart
// Don't use Navigator directly
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => ProfileScreen()),
);
```

### 6. Constants

✅ **DO:**
```dart
// Define constants in dedicated files
class AppColors {
  static const primary = Color(0xFF2196F3);
}

// Usage
color: AppColors.primary
```

❌ **DON'T:**
```dart
// Don't hardcode values
color: Color(0xFF2196F3)  // What color is this?
```

---

## Performance Optimizations

### 1. Provider Scope

```dart
// Keep providers alive when needed
@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  // This provider stays in memory
}

// Auto-dispose when not watched
@riverpod
Future<Data> tempData(TempDataRef ref) {
  // Disposed when no listeners
}
```

### 2. Selective Rebuilds

```dart
// Only rebuild when specific field changes
final name = ref.watch(
  profileViewModelProvider.select((state) =>
    state.value?.fullName
  ),
);
```

### 3. Lazy Loading

```dart
// Load data only when screen opens
@override
Future<Profile?> build() async {
  // Not loaded until ProfileScreen is opened
  return await fetchProfile();
}
```

---

## Summary

### Architecture Strengths

✅ **Scalable**: Feature-first structure grows easily
✅ **Maintainable**: Clear separation of concerns
✅ **Type-Safe**: Freezed + Riverpod + Dart 3
✅ **Testable**: ViewModels can be unit tested
✅ **Performant**: Selective rebuilds, lazy loading
✅ **Developer-Friendly**: Code generation reduces boilerplate

### Tech Stack Benefits

| Technology | Benefit |
|------------|---------|
| Riverpod 3.0 | Compile-time safety, auto-disposal |
| Freezed | Immutability, copyWith, equality |
| GoRouter | Declarative routing, type-safe |
| Dio | Interceptors, error handling |
| FlexColorScheme | Advanced Material 3 theming |

---

**Last Updated:** 2025-11-01
**Status:** Production Architecture
**Next Steps:** API integration, testing, deployment
