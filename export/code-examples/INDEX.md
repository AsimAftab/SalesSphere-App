# Code Examples Index

This folder contains **actual working code** from the SalesSphere project. Use these files as references when building new features.

---

## 📂 Folder Structure

```
code-examples/
├── widgets/           # Reusable UI components
├── screens/           # Complete screen implementations
├── models/            # Freezed data models
├── viewmodels/        # Riverpod ViewModels with business logic
├── constants/         # Constants and utilities
└── router/            # GoRouter configuration
```

---

## 1. Widgets (`widgets/`)

### `custom_button.dart` (488 lines)
**Complete button system with 5 variants**

**What's inside:**
- `CustomButton`: Base button component with full customization
- `PrimaryButton`: Blue filled button (most common)
- `SecondaryButton`: Dark blue filled button
- `OutlinedCustomButton`: Border-only button
- `GradientButton`: Gradient background button

**Button Types:**
```dart
enum ButtonType { primary, secondary, outlined, text, gradient }
```

**Button Sizes:**
```dart
enum ButtonSize { small, medium, large }
```

**Features:**
- Loading states (shows CircularProgressIndicator)
- Disabled states (grayed out)
- Leading/trailing icons
- Responsive sizing (.w, .h, .sp)
- Custom colors, borders, padding
- Elevation and shadows

**Usage Example:**
```dart
PrimaryButton(
  label: 'Submit',
  onPressed: () => _handleSubmit(),
  isLoading: isLoading,
  size: ButtonSize.medium,
  leadingIcon: Icons.send,
)
```

---

### `custom_text_field.dart` (249 lines)
**Beautiful, consistent text input component**

**What's inside:**
- `PrimaryTextField`: Main text input widget with full styling
- Built-in error handling with icon
- Focus border animations
- Disabled state styling
- Validation support

**Features:**
- Prefix/suffix icons and widgets
- Password visibility toggle support
- Multi-line support
- Custom validators
- Real-time error display
- Keyboard action handling
- Autofill hints
- Input formatters support
- Disabled state (grayed out)

**Usage Example:**
```dart
PrimaryTextField(
  hintText: "Email Address",
  controller: _emailController,
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => FieldValidators.validateEmail(value),
)
```

**Password Field Example:**
```dart
PrimaryTextField(
  hintText: "Password",
  controller: _passwordController,
  prefixIcon: Icons.lock_outline,
  obscureText: !_isPasswordVisible,
  suffixWidget: IconButton(
    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
  ),
)
```

---

## 2. Screens (`screens/`)

### `login_screen.dart` (358 lines)
**Complete login screen with form validation**

**What you'll learn:**
- Form structure with GlobalKey
- TextEditingController management
- Password visibility toggle
- Riverpod state management integration
- Loading states during API calls
- Error handling (field errors vs general errors)
- Navigation on success
- Gradient background with SVG bubbles
- Bottom sheet card design
- Keyboard handling

**Key Features:**
- Email and password fields with validation
- "Forgot Password?" link
- Login button with loading state
- Server-side error display
- Auto-navigation to home on success
- Beautiful gradient UI with logo
- Responsive design

**Code Highlights:**
```dart
// Listening to login state for navigation
ref.listen(loginViewModelProvider, (previous, next) {
  if (next is AsyncData && next.value != null) {
    context.go('/home');
  }
});

// Error extraction from async state
if (loginState is AsyncError) {
  if (loginState.error is Map<String, String>) {
    fieldErrors = loginState.error as Map<String, String>;
    generalError = fieldErrors['general'];
  }
}
```

---

### `forgot_password_screen.dart` (210 lines)
**Forgot password screen with dialog**

**What you'll learn:**
- Full-page AppBar design (vs bottom sheet)
- Hardware back button handling with PopScope
- Success dialog patterns
- Form validation
- Keyboard-aware scrolling
- Logo integration
- Simple form with single field

**Key Features:**
- AppBar with back button
- Logo display
- Email validation
- Success dialog on submit
- Hardware back button override
- Keyboard adjustment (resizeToAvoidBottomInset: true)
- "Remember password? Login" link

**Code Highlights:**
```dart
// Hardware back button handling
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) context.go('/');
  },
  child: Scaffold(...),
)

// Success dialog
void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          Text('Email Sent'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/');
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## 3. Models (`models/`)

### `login.models.dart` (92 lines)
**Complete auth models using Freezed**

**What you'll learn:**
- Freezed annotation patterns
- JSON serialization setup
- Nested model structures
- Required vs optional fields
- JsonKey annotations for field mapping

**Models included:**
- `LoginRequest`: Email + password
- `LoginResponse`: Status, token, data
- `LoginData`: Contains user object
- `User`: Complete user profile with all fields
- `Document`: File metadata

**Code Highlights:**
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

// Field mapping example
@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,  // Maps '_id' to 'id'
    required String name,
    required String email,
    String? avatarUrl,  // Optional field
  }) = _User;
}
```

---

### `forgot_password.models.dart` (35 lines)
**Simple request/response models**

**What you'll learn:**
- Minimal Freezed model structure
- Request/response pattern
- Simple JSON mapping

**Models included:**
- `ForgotPasswordRequest`: Just email
- `ForgotPasswordResponse`: Status + message

**Usage:**
```dart
// Creating request
final request = ForgotPasswordRequest(email: 'user@example.com');

// Converting to JSON for API
final json = request.toJson();

// Parsing response
final response = ForgotPasswordResponse.fromJson(responseData);
```

---

## 4. ViewModels (`viewmodels/`)

### `login.vm.dart` (142 lines)
**Complete authentication ViewModel**

**What you'll learn:**
- Riverpod 3.0 code generation pattern
- AsyncNotifier for async state
- Token persistence
- Error handling patterns
- Local validation before API calls
- Global state management
- Dio integration

**Key Features:**
- User restoration from saved token
- Local email/password validation
- Login method with full error handling
- Token storage integration
- Global user state update
- Comprehensive logging

**Code Highlights:**
```dart
@Riverpod(keepAlive: true)
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<LoginResponse?> build() async {
    // Auto-restore user from token on app start
    final token = await tokenStorage.getToken();
    if (token != null) {
      // Fetch profile and restore user
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final response = await dio.post(ApiEndpoints.login, data: {...});

      await tokenStorage.saveToken(response.token);
      ref.read(userControllerProvider.notifier).setUser(user);

      state = AsyncData(loginResponse);
    } on DioException catch (e) {
      // Handle different error codes
      if (e.response?.statusCode == 401) {
        state = AsyncError({'general': 'Invalid credentials'}, ...);
      }
    }
  }
}
```

---

### `forgot_password.vm.dart` (98 lines)
**Simple API call ViewModel**

**What you'll learn:**
- Basic Riverpod ViewModel structure
- Simple POST request
- Error state management
- Boolean return pattern
- Validation methods

**Code Highlights:**
```dart
@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  Future<ForgotPasswordResponse?> build() async {
    return null;
  }

  Future<bool> sendResetEmail(String email) async {
    state = const AsyncLoading();

    try {
      final response = await dio.post(ApiEndpoints.forgotPassword, data: {...});
      state = AsyncData(response);
      return true;  // Success
    } catch (e) {
      state = AsyncError(e, stackTrace);
      return false;  // Failure
    }
  }
}
```

---

## 5. Constants (`constants/`)

### `app_colors.dart` (86 lines)
**Complete color system**

**What you'll learn:**
- Color constant organization
- Primary/secondary color scheme
- Semantic colors (success, error, warning)
- Background and surface colors
- Text color hierarchy
- Border and divider colors
- Gradient definitions
- Shadow and overlay colors

**Color Categories:**
```dart
// Primary Colors
AppColors.primary        // #163355 - Dark Blue
AppColors.secondary      // #197ADC - Bright Blue

// Background
AppColors.background     // #F1F4FC - Light Blue-Gray
AppColors.surface        // #FFFFFF - White

// Text
AppColors.textPrimary    // #212121 - Almost Black
AppColors.textSecondary  // #757575 - Gray
AppColors.textHint       // #9E9E9E - Light Gray

// Status
AppColors.success        // #4CAF50 - Green
AppColors.error          // #B00020 - Red
AppColors.warning        // #FFA726 - Orange

// Utility
AppColors.border         // #E0E0E0
AppColors.shadow         // Black 10% opacity
```

---

### `api_endpoints.dart` (62 lines)
**Centralized API endpoint management**

**What you'll learn:**
- Endpoint organization by feature
- Static constants vs dynamic functions
- RESTful patterns

**Endpoint Categories:**
- Auth: login, register, forgot-password, etc.
- User: profile, update, delete
- Sales: CRUD operations
- Products: CRUD operations
- Parties: CRUD operations
- File upload
- Notifications
- Analytics

**Usage Examples:**
```dart
// Static endpoint
ApiEndpoints.login  // '/auth/login'

// Dynamic endpoint with ID
ApiEndpoints.partyById('123')  // '/parties/123'
ApiEndpoints.updateParty('456')  // '/parties/456'
```

---

### `field_validators.dart`
**Form validation utilities**

**What you'll learn:**
- Reusable validation functions
- Email validation with regex
- Password strength checks
- Required field validation
- Phone number validation

**Available Validators:**
```dart
FieldValidators.validateEmail(value)
FieldValidators.validatePassword(value)
FieldValidators.validatePhone(value)
FieldValidators.validateRequired(value, fieldName)
```

---

## 6. Router (`router/`)

### `route_handler.dart` (261 lines)
**Complete GoRouter configuration**

**What you'll learn:**
- GoRouter setup with Riverpod
- Authentication-based redirects
- Route protection
- Shell routes (with bottom navigation)
- Standalone routes (without bottom nav)
- Path parameters
- Extra data passing
- Error page handling

**Route Types:**
1. **Auth Routes**: Login, Forgot Password (no bottom nav)
2. **Standalone Routes**: Profile, About, Add Party (no bottom nav)
3. **Shell Routes**: Home, Catalog, Invoice, Parties, Settings (with bottom nav)

**Code Highlights:**
```dart
// Router provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(userControllerProvider);

  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = user != null;

      // Protect routes based on auth state
      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [...],
  );
});

// Route with parameters
GoRoute(
  path: '/detail/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    return DetailScreen(id: id);
  },
)

// Shell route (with bottom navigation)
ShellRoute(
  builder: (context, state, child) {
    return MainShell(child: child);
  },
  routes: [
    GoRoute(path: '/home', ...),
    GoRoute(path: '/catalog', ...),
  ],
)
```

---

## How to Use These Examples

### 1. **Learning a Pattern**
- Read the file comments
- Understand the structure
- Note the imports and annotations
- See how state is managed

### 2. **Building a New Feature**
- Copy the most similar example
- Modify for your use case
- Update model names and fields
- Adjust UI as needed
- Run code generation

### 3. **Troubleshooting**
- Compare your code with examples
- Check imports and annotations
- Verify code generation was run
- Ensure naming conventions match

---

## Code Generation Reminder

After creating/modifying files with these annotations:
- `@freezed` (models)
- `@riverpod` (ViewModels)
- `@JsonSerializable`

**Always run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` files
- `*.g.dart` files

---

## File Organization Tips

When creating new features, follow this structure:

```
lib/features/your_feature/
├── models/
│   └── your_feature.models.dart       (Use login.models.dart as template)
├── views/
│   └── your_feature_screen.dart       (Use forgot_password_screen.dart as template)
└── vm/
    └── your_feature.vm.dart           (Use forgot_password.vm.dart as template)
```

Then:
1. Copy similar example
2. Rename classes and files
3. Modify logic
4. Run code generation
5. Add route to `route_handler.dart`

---

## Quick Reference

| Need to... | Look at... |
|------------|------------|
| Create a button | `widgets/custom_button.dart` |
| Create a text field | `widgets/custom_text_field.dart` |
| Build a form screen | `screens/forgot_password_screen.dart` |
| Handle complex auth | `screens/login_screen.dart` |
| Create a model | `models/login.models.dart` |
| Build a ViewModel | `viewmodels/forgot_password.vm.dart` |
| Make API calls | `viewmodels/login.vm.dart` |
| Use colors | `constants/app_colors.dart` |
| Add endpoints | `constants/api_endpoints.dart` |
| Configure routes | `router/route_handler.dart` |

---

## Additional Resources

For explanations and guides, see the documentation files:
- `../PROJECT_OVERVIEW.md`
- `../REUSABLE_COMPONENTS.md`
- `../CREATING_NEW_PAGES.md`
- `../THEMING_AND_STYLING.md`
- `../CODE_EXAMPLES.md`

**Happy Coding! 🚀**
