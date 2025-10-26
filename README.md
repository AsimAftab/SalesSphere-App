# SalesSphere App 🚀

A modern, feature-rich Flutter application for sales management built with clean architecture, state management using Riverpod, and Material 3 design.

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Code Generation](#code-generation)
- [Architecture](#architecture)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## 📖 About

SalesSphere is a comprehensive sales management application designed to streamline sales operations, provide analytics, and enhance productivity. Built with Flutter, it offers a seamless cross-platform experience on iOS and Android devices.

## ✨ Features

- **🔐 Authentication System**
  - User login with email and password
  - Field-level validation (client-side and server-side)
  - Password visibility toggle
  - Forgot password flow
  - User registration
  
- **🎨 Modern UI/UX**
  - Material 3 design system
  - Custom theming with FlexColorScheme
  - Light and dark mode support
  - Responsive design using ScreenUtil
  - Custom color schemes and gradients
  
- **📱 Navigation**
  - Declarative routing with GoRouter
  - Type-safe navigation
  - Deep linking support
  
- **🔄 State Management**
  - Riverpod 3.0 for robust state management
  - Provider lifecycle logging
  - Async state handling
  
- **🌐 API Integration**
  - Dio for HTTP requests
  - Centralized API configuration
  - Error handling and retry logic
  
- **📊 Sales Management** (Planned)
  - Product catalog
  - Order management
  - Sales reporting
  - Analytics dashboard

## 🛠 Technology Stack

### Core Framework
- **Flutter SDK**: ^3.9.2
- **Dart**: Language for Flutter development

### State Management & Architecture
- **flutter_riverpod**: ^3.0.3 - State management solution
- **riverpod_annotation**: ^3.0.3 - Code generation for Riverpod
- **riverpod_generator**: ^3.0.3 - Generator for Riverpod providers
- **riverpod_lint**: ^3.0.3 - Linting rules for Riverpod

### Navigation
- **go_router**: ^16.3.0 - Declarative routing

### UI & Design
- **flex_color_scheme**: ^8.3.1 - Advanced theming
- **flutter_screenutil**: ^5.9.3 - Responsive UI scaling
- **flutter_svg**: ^2.2.1 - SVG rendering support
- **cupertino_icons**: ^1.0.8 - iOS style icons

### Networking
- **dio**: ^5.9.0 - HTTP client for API calls

### Data Persistence
- **shared_preferences**: ^2.5.3 - Local key-value storage

### Serialization & Code Generation
- **freezed**: ^3.2.3 - Immutable data classes
- **freezed_annotation**: ^3.1.0 - Annotations for Freezed
- **freezed_lint**: ^0.0.12 - Linting for Freezed
- **json_annotation**: ^4.9.0 - JSON serialization annotations
- **json_serializable**: ^6.11.1 - JSON code generation

### Utilities
- **logger**: ^2.6.2 - Advanced logging
- **flutter_dotenv**: ^6.0.0 - Environment variable management

### Development Tools
- **build_runner**: ^2.7.1 - Code generation runner
- **custom_lint**: ^0.8.0 - Custom linting rules
- **flutter_lints**: ^6.0.0 - Recommended Flutter lints

## 📁 Project Structure

```
sales_sphere/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/
│   ├── app.dart         # Main app widget with router configuration
│   ├── main.dart        # App entry point
│   ├── core/            # Core functionality
│   │   ├── constants/   # App-wide constants
│   │   │   ├── api_constants.dart      # API endpoints and configs
│   │   │   ├── app_assets.dart         # Asset paths
│   │   │   ├── app_colors.dart         # Color palette
│   │   │   ├── app_constants.dart      # General constants
│   │   │   ├── app_sizes.dart          # Size constants
│   │   │   ├── app_strings.dart        # Text strings
│   │   │   ├── constants.dart          # Barrel file
│   │   │   └── storage_keys.dart       # Storage key constants
│   │   ├── router/      # Navigation configuration
│   │   │   └── route_handler.dart      # GoRouter setup
│   │   ├── theme/       # Theme configuration
│   │   │   ├── theme.dart              # Light/Dark themes
│   │   │   ├── theme_notifier.dart     # Theme state management
│   │   │   └── theme_notifier.g.dart   # Generated code
│   │   └── utils/       # Utility functions
│   │       └── logger.dart             # Logging utility
│   └── features/        # Feature modules
│       └── auth/        # Authentication feature
│           ├── models/  # Data models
│           │   ├── login_model.dart
│           │   ├── login_model.freezed.dart
│           │   └── login_model.g.dart
│           ├── views/   # UI screens
│           │   └── login_screen.dart
│           └── vm/      # View models (business logic)
│               ├── login.vm.dart
│               └── login.vm.g.dart
├── test/                # Test files
│   └── widget_test.dart
├── .env                 # Environment variables (not in git)
├── .gitignore          # Git ignore rules
├── analysis_options.yaml # Linting configuration
├── pubspec.yaml        # Dependencies
└── README.md           # This file
```

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.2 or higher)
  - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **Xcode** (for mobile development)
- **Git** (for version control)
- A code editor: **VS Code** or **Android Studio** recommended

### Verify Installation

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

## 🚀 Installation

1. **Clone the repository**

```bash
git clone https://github.com/AsimAftab/SalesSphere-App.git
cd SalesSphere-App
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Generate code** (for Riverpod, Freezed, and JSON serialization)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## ⚙️ Configuration

### Environment Variables

1. Create a `.env` file in the root directory (copy from `.env.example` if available)

```bash
# .env
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here
APP_NAME=Sales Sphere
```

2. Update the values according to your environment:
   - **API_BASE_URL**: Your backend API base URL
   - **API_KEY**: API authentication key (if required)
   - **APP_NAME**: Application name

### API Configuration

API endpoints are configured in `lib/core/constants/api_constants.dart`. Update the base URLs for different environments:

```dart
static const String baseUrlDev = 'https://dev-api.example.com';
static const String baseUrlStaging = 'https://staging-api.example.com';
static const String baseUrlProduction = 'https://api.example.com';
```

## 🏃 Running the App

### Development Mode

```bash
# Run on default device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>

# Run with hot reload (default)
flutter run --hot
```

### Build for Release

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build IPA
flutter build ios --release

# Build and archive (requires Xcode)
flutter build ipa --release
```

## 🔧 Code Generation

This project uses code generation for:
- **Riverpod** providers
- **Freezed** immutable models
- **JSON** serialization

### Watch Mode (Recommended for Development)

Run in watch mode to automatically regenerate code on file changes:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### One-Time Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean and Rebuild

If you encounter issues with generated code:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🏗 Architecture

SalesSphere follows **Clean Architecture** principles with a feature-first structure:

### Layers

1. **Presentation Layer** (`views/` and `vm/`)
   - UI widgets and screens
   - View Models for business logic
   - State management with Riverpod

2. **Domain Layer** (`models/`)
   - Business entities
   - Immutable data classes using Freezed

3. **Core Layer** (`core/`)
   - Shared utilities and configurations
   - Constants, themes, routing
   - Cross-cutting concerns

### Key Patterns

- **Feature-First Structure**: Code organized by features (auth, sales, etc.)
- **Provider Pattern**: Riverpod for dependency injection and state management
- **Repository Pattern**: (To be implemented) For data access abstraction
- **MVVM**: View Models handle business logic, Views handle UI

### State Management

Using **Riverpod 3.0** with code generation:

```dart
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<void> build() async {
    // Initialization
  }

  Future<void> login(String email, String password) async {
    // Business logic
  }
}
```

### Immutable Models

Using **Freezed** for immutable data classes:

```dart
@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel({
    required String email,
    required String password,
  }) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
}
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Test Structure

```
test/
├── unit/         # Unit tests
├── widget/       # Widget tests
└── integration/  # Integration tests
```

### Writing Tests

```dart
testWidgets('Login screen displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('Login'), findsOneWidget);
});
```

## 📱 Device Support

- **iOS**: 12.0+
- **Android**: API 21+ (Android 5.0 Lollipop)

## 🎨 Theming

The app uses **FlexColorScheme** for advanced theming:

- Material 3 design
- Custom color schemes
- Light and dark mode support
- Consistent component theming

Theme configuration: `lib/core/theme/theme.dart`

## 📝 Linting and Code Quality

The project uses Flutter lints and custom rules:

```bash
# Run linter
flutter analyze

# Format code
flutter format .
```

Configuration: `analysis_options.yaml`

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Run tests and linter**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Keep functions small and focused

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Asim Aftab** - [GitHub Profile](https://github.com/AsimAftab)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod community for state management solutions
- Open source contributors

## 📞 Support

For support, email asim@example.com or open an issue in the GitHub repository.

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [FlexColorScheme Documentation](https://pub.dev/packages/flex_color_scheme)

---

**Made with ❤️ using Flutter**
