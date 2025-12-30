# SalesSphere App - Developer Context

This file provides comprehensive context for AI agents (and developers) working on the SalesSphere Flutter application.

## 🚀 Project Overview

**SalesSphere** is a robust sales management application built with Flutter, designed for cross-platform performance (Android/iOS). It features a modern Clean Architecture, state management via Riverpod 3.0, and a feature-first folder structure.

*   **Primary Goal:** Streamline sales operations, tracking, and analytics.
*   **Key Features:** Auth, Beat Plans, Expense Claims, Real-time Tracking (Socket.io/Background Service), Offline Support (Hive), and Analytics.
*   **Design:** Material 3 with FlexColorScheme, responsive UI via ScreenUtil.

## 🛠 Tech Stack & Dependencies

| Category | Technology | Key Package(s) |
| :--- | :--- | :--- |
| **Framework** | Flutter (SDK ^3.9.2), Dart | `flutter` |
| **State Management** | Riverpod 3.0 | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` |
| **Routing** | GoRouter | `go_router` |
| **Networking** | Dio | `dio`, `pretty_dio_logger`, `socket_io_client` |
| **Data/Serialization**| Freezed, JSON Serializable | `freezed`, `json_serializable`, `freezed_annotation` |
| **Local Storage** | Shared Preferences, Hive | `shared_preferences`, `hive`, `hive_flutter` |
| **UI/Theming** | FlexColorScheme, ScreenUtil | `flex_color_scheme`, `flutter_screenutil`, `flutter_svg`, `skeletonizer` |
| **Maps/Location** | Google Maps, Geolocator | `google_maps_flutter`, `geolocator`, `flutter_background_service` |
| **Utils** | Logger, DotEnv | `logger`, `flutter_dotenv` |
| **Error Tracking** | Sentry | `sentry_flutter` |

## 🏗 Architecture

The project follows a **Clean Architecture** with a **Feature-First** directory structure.

### Directory Structure (`lib/`)
*   **`main.dart`**: App entry point. Initializes services (DotEnv, Hive, Sentry, Notifications) and wraps the app in `ProviderScope`.
*   **`app.dart`**: Root widget. Configures `ScreenUtil`, `MaterialApp.router`, global connectivity handling, and app startup logic.
*   **`core/`**: Shared resources across the app.
    *   `constants/`: App-wide constants (colors, api endpoints, assets).
    *   `network_layer/`: Dio client setup, interceptors, exception handling (`dio_client.dart`, `api_endpoints.dart`).
    *   `router/`: GoRouter configuration (`route_handler.dart`).
    *   `theme/`: Theme definitions.
    *   `services/`: Core services like `OfflineQueueService`, `TrackingCoordinator`.
    *   `utils/`: Helpers like `AppLogger`.
*   **`features/`**: Feature-specific modules (e.g., `auth`, `beat_plan`, `home`).
    *   `views/`: UI Screens.
    *   `vm/`: ViewModels (Riverpod `AsyncNotifier`s).
    *   `models/`: Data models (Freezed classes).
*   **`widget/`**: Reusable global widgets.

### Key Patterns
1.  **State Management**: Uses `riverpod_generator` (`@riverpod` annotation). ViewModels typically extend `_$ClassName`.
2.  **Immutability**: All models use `@freezed`.
3.  **Networking**:
    *   Use `ref.read(dioClientProvider)` for API calls.
    *   Base URL and keys are in `.env`.
    *   Endpoints are defined in `lib/core/network_layer/api_endpoints.dart`.
4.  **Logging**: strictly use `AppLogger` (`d`, `i`, `w`, `e`). **NO `print()`**.

## 💻 Development Workflow

### Prerequisite Checks
*   Ensure `.env` exists (copy from example if needed).
*   Flutter SDK version matches `pubspec.yaml`.

### Common Commands

**Run App:**
```bash
flutter run
```

**Code Generation (Crucial for Riverpod/Freezed):**
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (Recommended during dev)
dart run build_runner watch --delete-conflicting-outputs
```

**Testing:**
```bash
flutter test
```

**Linting:**
```bash
flutter analyze
```

### Creating a New Feature
1.  Create folder: `lib/features/<feature_name>`.
2.  Add subfolders: `models`, `views`, `vm`.
3.  Define Models using `@freezed`.
4.  Define ViewModel using `@riverpod`.
5.  Create UI in `views`.
6.  Register route in `lib/core/router/route_handler.dart`.
7.  Run `build_runner`.

## ⚠️ Important Rules
*   **Do not use `print`**. Use `AppLogger`.
*   **Portrait Only**: The app is locked to portrait mode in `main.dart`.
*   **Connectivity**: The app has a global `GlobalConnectivityWrapper` to handle offline states.
*   **Background Services**: Tracking logic runs in a background service; be careful when modifying `TrackingCoordinator` or `NotificationPermissionService`.
