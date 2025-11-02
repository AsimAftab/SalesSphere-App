# Code Examples & Snippets

Practical, copy-paste ready code examples from the SalesSphere project.

---

## Table of Contents
1. [Complete Screen Examples](#complete-screen-examples)
2. [Riverpod ViewModels](#riverpod-viewmodels)
3. [Freezed Models](#freezed-models)
4. [Form Handling](#form-handling)
5. [Navigation Patterns](#navigation-patterns)
6. [API Calls](#api-calls)
7. [State Management](#state-management)
8. [Common UI Patterns](#common-ui-patterns)

---

## Complete Screen Examples

### Example 1: Forgot Password Screen (Full)
**File**: `lib/features/auth/views/forgot_password_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Backend integration will be added later
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
            SizedBox(width: 12.w),
            const Text('Email Sent'),
          ],
        ),
        content: Text(
          'A password reset link has been sent to your email address.',
          style: TextStyle(fontSize: 14.sp),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'Forgot Password',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),

                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 100.h,
                      width: 100.w,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Title
                  Text(
                    'Reset Your Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Description
                  Text(
                    "Enter your email address and we'll send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Email Field
                  PrimaryTextField(
                    hintText: "Email Address",
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    hasFocusBorder: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSubmit(),
                    validator: (value) => FieldValidators.validateEmail(value),
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  PrimaryButton(
                    label: 'Send Reset Link',
                    onPressed: _handleSubmit,
                    size: ButtonSize.medium,
                  ),

                  SizedBox(height: 24.h),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Riverpod ViewModels

### Example 1: Simple ViewModel with Validation

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_view_model.vm.g.dart';

@riverpod
class MyViewModel extends _$MyViewModel {
  @override
  Future<String?> build() async {
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  Future<void> submitForm(String email) async {
    state = const AsyncLoading();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      state = const AsyncData('Success');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
```

### Example 2: ViewModel with API Call

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/my_model.dart';

part 'my_api.vm.g.dart';

@riverpod
class MyApiViewModel extends _$MyApiViewModel {
  @override
  Future<MyResponse?> build() async {
    return null;
  }

  Future<void> fetchData(String id) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.i('📡 Fetching data for ID: $id');

      final response = await dio.get('${ApiEndpoints.myEndpoint}/$id');

      if (response.statusCode == 200) {
        final myResponse = MyResponse.fromJson(response.data);
        state = AsyncData(myResponse);
        AppLogger.i('✅ Data fetched successfully');
      } else {
        throw Exception('Failed to fetch data');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ API call failed', e);
      state = AsyncError(e, StackTrace.current);
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error', e, stack);
      state = AsyncError(e, stack);
    }
  }
}
```

---

## Freezed Models

### Example 1: Simple Data Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.model.freezed.dart';
part 'user.model.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Example 2: Request/Response Models

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.models.freezed.dart';
part 'auth.models.g.dart';

// Request Model
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

// Response Model
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String status,
    required String token,
    required UserData data,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

// Nested Model
@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    required String id,
    required String name,
    required String email,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
```

---

## Form Handling

### Example 1: Complete Form with Validation

```dart
class MyFormScreen extends ConsumerStatefulWidget {
  const MyFormScreen({super.key});

  @override
  ConsumerState<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends ConsumerState<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Handle form submission
      AppLogger.i('Form submitted: $name, $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Example')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                PrimaryTextField(
                  hintText: "Name",
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                PrimaryTextField(
                  hintText: "Email",
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => FieldValidators.validateEmail(value),
                ),
                SizedBox(height: 32.h),
                PrimaryButton(
                  label: 'Submit',
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Example 2: Password Field with Visibility Toggle

```dart
bool _isPasswordVisible = false;

PrimaryTextField(
  hintText: "Password",
  controller: _passwordController,
  prefixIcon: Icons.lock_outline,
  obscureText: !_isPasswordVisible,
  suffixWidget: IconButton(
    icon: Icon(
      _isPasswordVisible
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
    ),
    onPressed: () {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    },
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  },
)
```

---

## Navigation Patterns

### Example 1: Basic Navigation

```dart
// Navigate to route
context.go('/home');

// Navigate with parameters
context.go('/profile/${userId}');

// Navigate with query parameters
context.go('/search?query=flutter');

// Go back
context.go('/');
```

### Example 2: Navigation with Data Passing

```dart
// In route definition (route_handler.dart)
GoRoute(
  path: '/detail/:id',
  name: 'detail',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? '';
    final extra = state.extra as Map<String, dynamic>?;
    return DetailScreen(id: id, data: extra);
  },
),

// Navigate with extra data
context.go(
  '/detail/123',
  extra: {'name': 'John', 'age': 25},
);
```

### Example 3: Hardware Back Button Handling

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) {
      context.go('/home');
    }
  },
  child: Scaffold(...),
)
```

---

## API Calls

### Example 1: GET Request

```dart
Future<void> fetchUsers() async {
  final dio = ref.read(dioClientProvider);

  try {
    final response = await dio.get(ApiEndpoints.users);

    if (response.statusCode == 200) {
      final users = (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
      // Handle users
    }
  } on DioException catch (e) {
    AppLogger.e('Failed to fetch users', e);
  }
}
```

### Example 2: POST Request

```dart
Future<void> createUser(String name, String email) async {
  final dio = ref.read(dioClientProvider);

  try {
    final response = await dio.post(
      ApiEndpoints.users,
      data: {
        'name': name,
        'email': email,
      },
    );

    if (response.statusCode == 201) {
      AppLogger.i('User created successfully');
    }
  } on DioException catch (e) {
    AppLogger.e('Failed to create user', e);
  }
}
```

### Example 3: With Authorization Token

```dart
// Token is automatically added by AuthInterceptor
// Just use dioClientProvider normally

Future<void> getProfile() async {
  final dio = ref.read(dioClientProvider);

  try {
    final response = await dio.get(ApiEndpoints.profile);
    // Token is automatically included in headers
  } on DioException catch (e) {
    AppLogger.e('Failed to get profile', e);
  }
}
```

---

## State Management

### Example 1: Watching State

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final userState = ref.watch(userViewModelProvider);

  return userState.when(
    data: (user) => Text('Hello ${user.name}'),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

### Example 2: Reading State (One-time)

```dart
void _handleSubmit() {
  final vm = ref.read(loginViewModelProvider.notifier);
  vm.login(email, password);
}
```

### Example 3: Listening to State Changes

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Listen for navigation
  ref.listen(loginViewModelProvider, (previous, next) {
    if (next is AsyncData && next.value != null) {
      context.go('/home');
    }
  });

  return Scaffold(...);
}
```

---

## Common UI Patterns

### Example 1: Loading Overlay

```dart
Stack(
  children: [
    // Main content
    YourContent(),

    // Loading overlay
    if (isLoading)
      Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
  ],
)
```

### Example 2: Empty State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.inbox_outlined,
        size: 64.sp,
        color: AppColors.textSecondary,
      ),
      SizedBox(height: 16.h),
      Text(
        'No items found',
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ),
)
```

### Example 3: Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(myViewModelProvider.notifier).refresh();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ListTile(title: Text(items[index].name));
    },
  ),
)
```

### Example 4: Confirmation Dialog

```dart
void _showConfirmDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleDelete();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

---

## Quick Snippets

### Logger
```dart
AppLogger.d('Debug message');
AppLogger.i('Info message');
AppLogger.w('Warning message');
AppLogger.e('Error message', error, stackTrace);
```

### Token Management
```dart
final tokenStorage = ref.read(tokenStorageServiceProvider);

// Save token
await tokenStorage.saveToken(token);

// Get token
final token = await tokenStorage.getToken();

// Clear auth data
await tokenStorage.clearAuthData();
```

### Responsive Sizing
```dart
// Width/Height
Container(width: 200.w, height: 100.h)

// Font size
Text('Hello', style: TextStyle(fontSize: 14.sp))

// Border radius
BorderRadius.circular(12.r)

// Padding
EdgeInsets.all(16.w)
```

---

## Next Steps

- **Project Overview**: See `PROJECT_OVERVIEW.md`
- **Components**: See `REUSABLE_COMPONENTS.md`
- **Creating Pages**: See `CREATING_NEW_PAGES.md`
- **Theming**: See `THEMING_AND_STYLING.md`
