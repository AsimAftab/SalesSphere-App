# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SalesSphere is a Flutter application for sales management with real-time tracking capabilities. Built with Riverpod 3.0 for state management, GoRouter for navigation, and code generation tools (Freezed, json_serializable, riverpod_generator). Key features include attendance tracking, beat plan tracking with WebSocket, invoicing, catalog management, and offline-first architecture.

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

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
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
- Use `@Riverpod(keepAlive: true)` for providers that should persist across navigation

### App Initialization Flow
1. `main.dart` initializes token storage and loads `.env`
2. `authInitProvider` checks for stored token and loads user data
3. On success: `UserController` gets user, `PermissionController` loads cached permissions/subscription
4. Router redirects based on auth state

### Global State Providers (keepAlive=true)
- `userControllerProvider` - Current logged-in user data (`User?`)
- `permissionControllerProvider` - Permissions, subscription, access flags (`PermissionState`)
- `tokenStorageServiceProvider` - JWT token storage service
- `sharedPrefsProvider` - SharedPreferences instance
- `appStartupProvider` - App startup state management
- `trackingCoordinatorProvider` - Real-time tracking orchestrator singleton

### Routing: GoRouter
- Centralized routing in `lib/core/router/route_handler.dart`
- Router is provided via `goRouterProvider` and watched by the App widget
- Routes use declarative GoRoute configuration with redirect guards
- `refreshListenable` on auth state changes triggers router rebuild without full app rebuild
- Module-based access control via `ModuleConfig` - checks `enabledModules` from subscription
- ShellRoute for bottom navigation with dynamic tab calculation based on enabled modules

### Models: Freezed + JSON Serializable
- All data models use `@freezed` annotation for immutability and code generation
- Requires `part 'model_name.freezed.dart'` and `part 'model_name.g.dart'`
- Provides `fromJson`/`toJson`, `copyWith`, equality, and union types
- Add `const Model._();` private constructor to enable custom getters/methods

### Feature-First Structure
```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── network_layer/  # Dio client, interceptors, token storage
│   ├── providers/      # Global providers (UserController, PermissionController)
│   ├── router/         # GoRouter configuration
│   ├── theme/          # FlexColorScheme-based theming
│   └── utils/          # Logger, validators
├── features/
│   ├── auth/           # Login, forgot password
│   ├── profile/        # User profile screen
│   ├── home/           # Home/dashboard
│   ├── attendance/     # Attendance tracking
│   ├── parties/        # Party management
│   ├── products/       # Product catalog
│   ├── invoice/        # Invoice management
│   └── ...
│   └── [feature]/
│       ├── models/     # Freezed data models
│       ├── views/      # UI screens
│       └── vm/         # ViewModels (AsyncNotifiers)
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

### Field Validators
Available in `lib/core/utils/field_validators.dart`:
- `validateEmail()` - Email format validation
- `validatePassword(minLength)` - Minimum length check
- `validateStrongPassword()` - Requires uppercase, lowercase, number, special char
- `validatePhone(minLength)` - Numeric only with minimum length
- `validateRequired([fieldName])` - Not empty after trim
- `validateUrl()` - URL format validation
- `validateNumeric()` - Valid number
- `validateLength(min, max)` - Min/max length constraints
- `validatePAN()` - Indian PAN format (5 letters, 4 digits, 1 letter)
- `validateGST()` - Indian GST format (15 characters)
- `validateMatch(fieldToMatch, [fieldName])` - Field matching
- `validateAge(minAge)` - Age validation from date of birth
- `validateRegex(pattern, errorMessage)` - Custom regex validation
- `combine(List<Validator>)` - Combine multiple validators

### Other Utilities
- `AppLogger` in `lib/core/utils/logger.dart` - Centralized logging with colored output
- `DateFormatter` in `lib/core/utils/date_formatter.dart` - Date formatting helpers
- `SnackbarUtils` in `lib/core/utils/snackbar_utils.dart` - Snackbar helpers
- `ConnectivityUtils` in `lib/core/utils/connectivity_utils.dart` - Network status helpers

## Key Dependencies

### Core
- **flutter_riverpod**: ^3.0.3 (state management)
- **riverpod_annotation**: ^3.0.3 + riverpod_generator (code generation)
- **go_router**: ^16.3.0 (declarative routing)
- **freezed**: ^3.2.3 + freezed_annotation (immutable models)
- **json_serializable**: ^6.11.1 (JSON serialization)
- **dio**: ^5.9.0 (HTTP client)

### UI & Design
- **flutter_screenutil**: ^5.9.3 (responsive sizing)
- **flex_color_scheme**: ^8.3.1 (advanced theming)
- **skeletonizer**: ^2.1.0+1 (loading skeletons)
- **cached_network_image**: 3.4.1 (image caching)
- **table_calendar**: ^3.1.2 (calendar widget)
- **wechat_assets_picker**: ^9.5.0 (media selection - multiple images/files)
- **photo_view**: ^0.15.0 (image zoom/pan viewer)

### Tracking & Location
- **socket_io_client**: ^2.0.3+1 (WebSocket for real-time tracking)
- **flutter_background_service**: ^5.1.0 (background execution)
- **flutter_local_notifications**: ^19.5.0 (foreground service notifications)
- **geolocator**: ^14.0.2 (GPS location)
- **geocoding**: ^4.0.0 (reverse geocoding)
- **google_maps_flutter**: ^2.13.1 (map display)
- **connectivity_plus**: ^7.0.0 (network status)
- **hive**: ^2.2.3 + hive_flutter (offline location queuing)

### Utilities
- **logger**: ^2.6.2 (logging)
- **flutter_dotenv**: ^6.0.0 (environment variables)
- **shared_preferences**: ^2.5.3 (local storage)
- **url_launcher**: ^6.3.2 (deep links)
- **intl**: ^0.20.2 (date formatting)
- **uuid**: ^4.5.1 (unique IDs)
- **image_picker**: ^1.2.0 (photo selection - single images)
- **wechat_assets_picker**: ^9.5.0 (media selection - multiple images/files)
- **path_provider**: ^2.1.5 (file paths)
- **pdf**: ^3.11.3 + open_file: ^3.5.9 (PDF generation)
- **permission_handler**: ^11.3.1 (runtime permissions)
- **sentry_flutter**: ^9.8.0 (error tracking)
- **battery_plus**: ^5.0.2 (battery status)
- **share_plus**: ^10.1.3 (content sharing)
- **file_picker**: ^10.3.8 (file selection)

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
**IMPORTANT:** Order matters! Interceptors are applied in the sequence listed below.
1. **ConnectivityInterceptor**: MUST be first - blocks requests when offline using `connectivity_plus`
2. **AuthInterceptor**: Adds `Authorization: Bearer {token}` header, handles automatic token refresh on 401, infinite loop prevention
3. **PrettyDioLogger**: Beautiful request/response logs (debug mode only)
4. **LoggingInterceptor**: Custom colored logging with ASCII borders (debug mode only)
5. **ErrorInterceptor**: Transforms DioErrors into `NetworkException` with user-friendly messages

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

### API Request/Response Patterns
- Use `@JsonKey(includeIfNull: false)` on optional request model fields to exclude null values from JSON
- This prevents sending null/empty fields to the API which can cause validation errors
- Example for UpdateCollectionRequest:
```dart
@freezed
abstract class UpdateCollectionRequest with _$UpdateCollectionRequest {
  const factory UpdateCollectionRequest({
    required double amountReceived,
    String? receivedDate,
    @JsonKey(includeIfNull: false) String? bankName,
    @JsonKey(includeIfNull: false) String? chequeNumber,
  }) = _UpdateCollectionRequest;
}
```
- Response wrappers typically follow the pattern:
```dart
@freezed
abstract class ApiResponse with _$ApiResponse {
  const factory ApiResponse({
    required bool success,
    required int count,
    required List<Data> data,
  }) = _ApiResponse;
}
```

## Important Model Details

### User/Profile Models
- `customRoleId` is a `CustomRole?` object (not a string) with nested permissions
- `organizationId` uses `OrganizationConverter` to handle both string ID and full object
- `displayRole` getter returns `customRoleId.name` if available, otherwise falls back to `role`
- Date fields in Profile use `DateTime?`, User model uses `String?`

### Subscription Model
- API returns `planTier` (not `tier`) - mapped via `@JsonKey(name: 'planTier')`
- `maxEmployees` and `isActive` are optional (not sent by API)
- `enabledModules` is required list of module names

### CustomRole Model
- Contains role details: `_id`, `name`, `description`, `permissions`
- Has `mobileAppAccess` and `webPortalAccess` boolean flags
- Used for granular permission control (vs base `role` field for admin/user)

## Real-Time Tracking Architecture

### Overview
The app has a sophisticated real-time beat plan tracking system that works offline-first. Location data is queued locally via Hive and synced when connectivity is restored. Tracking continues in background using a foreground service with rich notifications.

### Core Components

**1. TrackingCoordinator** (`lib/core/services/tracking_coordinator.dart`)
- Singleton master orchestrator for all tracking components
- Integrates: LocationTrackingService, TrackingSocketService, OfflineQueueService, BackgroundTrackingService
- Handles session recovery after app restart (checks API for active session, falls back to SharedPreferences)
- States: `idle`, `starting`, `active`, `paused`, `stopping`, `stopped`, `forceStopped`, `error`

**2. TrackingSocketService** (`lib/core/services/tracking_socket_service.dart`)
- WebSocket connection using `socket_io_client`
- JWT auth via `setAuth({'token': token})`
- Events: `tracking-started`, `location-update`, `tracking-paused/resumed`, `tracking-stopped`, `tracking-force-stopped`
- Transports: WebSocket (primary), polling (fallback)
- 10-second connection timeout, exponential backoff reconnection

**3. BackgroundTrackingService** (`lib/core/services/background_tracking_service.dart`)
- Foreground service keeps tracking alive when app is minimized
- Runs in separate isolate with continuous location stream
- Rich notification shows: current address, X/Y directories visited, distance, duration, progress bar
- **Reverse geocoding** with 5-second timeout (non-blocking) to convert coordinates to addresses
- Hive storage for offline location queuing
- Notification channel: `tracking_channel` / `Beat Plan Tracking`, ID: 888

**4. LocationService** (`lib/core/services/location_service.dart`)
- Wrapper around `geolocator` package
- Methods: `isLocationServiceEnabled()`, `requestLocationPermission()`, `getCurrentLocation()`
- Returns `LatLng` from `google_maps_flutter`

### Tracking Flow

**Start Tracking:**
1. Check notification permission (Android 13+)
2. Save progress to SharedPreferences
3. Connect to socket (optional - works offline)
4. Start location tracking (foreground + background)
5. Subscribe to location updates
6. Start periodic sync timer (1 minute intervals)

**Stop Tracking:**
1. Stop location and background services
2. Send stop command to server (if connected)
3. Sync remaining queued locations
4. Disconnect socket
5. Clear SharedPreferences

### Environment Variables Required
```
API_BASE_URL=https://api.yourdomain.com
WEBSOCKET_PATH=/live/tracking
```

## Conventions

- **ViewModels**: Named with `.vm.dart` suffix, use AsyncNotifier pattern
- **Models**: Use Freezed for all data classes requiring immutability/serialization
- **Validation**: Field validators in `lib/core/utils/field_validators.dart`
- **Constants**: Organized by type (colors, sizes, strings, API, storage) in `lib/core/constants/`
- **Storage Keys**: Centralized in `lib/core/constants/storage_keys.dart`
- **Portrait-only**: App locked to portrait orientation (configured in main.dart)
- **Error Handling**: Global Flutter error handler logs to AppLogger in main.dart, Sentry for crash reporting
- **Network Calls**: Always use `dioClientProvider`, handle `NetworkException`

### Shared Widgets
Common reusable widgets in `lib/widget/`:
- `CustomTextField` - Primary text input field with validation
- `CustomButton` - Themed button variants
- `CustomDropdownTextField` - Dropdown selection field
- `PrimaryAsyncDropdown` - Async data loading dropdown
- `PrimaryImagePicker` - Image selection widget
- `CustomDatePicker` - Date selection widget
- `LocationPickerWidget` - Location selection with map
- `AsyncValueHandler` - Handles loading/error states for AsyncValue
- `ErrorHandlerWidget` - Consistent error display
- `PermissionDeniedWidget` - Permission request UI
- `ConnectivityBanner` - Offline status banner
- `UtilityCard` - Utility menu grid item
- `UniversalListCard` - Generic list item card
- `DirectoryOptionsSheet` - Bottom sheet for directory options (parties/prospects/sites)

### Navigation Conventions
**CRITICAL: Always use GoRouter for navigation - never use imperative Navigator methods.**

The app uses GoRouter (`go_router` package) for all navigation. Do NOT use:
- `Navigator.push()`
- `Navigator.pop()`
- `Navigator.of(context).pop()`
- `MaterialPageRoute` or `CupertinoPageRoute`

**Instead, use GoRouter methods:**
```dart
import 'package:go_router/go_router.dart';

// Navigate to a route
context.push('/route-path');

// Navigate with data (use extra parameter)
context.push('/attendance-detail', extra: attendanceObject);

// Go back
context.pop();

// Replace current route
context.replace('/new-route');

// Go to named route
context.goNamed('route-name');
```

**Adding new routes:**
1. Define the route in `lib/core/router/route_handler.dart`
2. Import the screen widget at the top of the file
3. Add a `GoRoute` entry with path, name, and builder
4. For routes that receive data via `extra`, cast it appropriately in the builder

Example route definition:
```dart
GoRoute(
  path: '/attendance-detail',
  name: 'attendance-detail',
  builder: (context, state) {
    final attendance = state.extra as SearchedAttendance;
    return AttendanceDetailScreen(attendance: attendance);
  },
),
```

## Module-Based Access Control

The app uses a subscription-based module system to control feature access:

**ModuleConfig System** (`lib/core/constants/module_config.dart`):
- Maps UI components (routes, tabs, utilities) to subscription's `enabledModules` list
- Modules organized into: `navTabModules`, `directoryModules`, `utilityModules`
- Always accessible routes: splash, onboarding, login, profile, settings
- Dynamic tab index calculation based on enabled modules
- Access redirects to home with snackbar when attempting to access disabled modules

**Navigation Tab Structure** (based on enabled modules):
- Index 0: Home (dashboard) - always visible
- Index 1: Catalog (products)
- Index 2: Invoice (invoices) - with floating action button, includes Estimates
- Index 3: Directory (parties/prospects/sites) - shows directory options sheet
- Index 4: Utilities (collection, expense claims, etc.) - shows utilities grid

**Available Modules** (from `ModuleConfig.modules`):
- Core tabs: `dashboard`, `products`, `invoices`, `estimates`
- Directory: `parties`, `prospects`, `sites`
- Utilities: `attendance`, `leaves`, `odometer`, `expenses`, `notes`, `collections`, `tourPlan`, `miscellaneousWork`
- Other: `beatPlan` (standalone, not in nav)

**Usage in routes**:
```dart
// Check module access before allowing navigation
redirect: (context, state) {
  final enabledModules = ref.read(permissionControllerProvider).enabledModules;
  if (!ModuleConfig.isAccessible('catalog', enabledModules)) {
    return '/home';
  }
  return null;
}
```
