# Creating New Pages - Step-by-Step Guide

This guide shows you how to create new pages/screens in the SalesSphere app using existing patterns and components.

---

## Table of Contents
1. [Quick Checklist](#quick-checklist)
2. [Full Example: Creating a Registration Page](#full-example-creating-a-registration-page)
3. [Pattern Templates](#pattern-templates)
4. [Common Page Types](#common-page-types)

---

## Quick Checklist

When creating a new page, follow these steps:

- [ ] Create feature folder (if new feature)
- [ ] Create models (if needed)
- [ ] Create ViewModel (if has business logic)
- [ ] Create view/screen file
- [ ] Run code generation (if using Freezed/Riverpod)
- [ ] Add route to `route_handler.dart`
- [ ] Test navigation
- [ ] Add hardware back button handling (if needed)

---

## Full Example: Creating a Registration Page

Let's create a complete registration page from scratch.

### Step 1: Create Folder Structure

```bash
lib/features/auth/
├── models/
│   └── register.models.dart  # NEW
├── views/
│   ├── login_screen.dart
│   └── register_screen.dart  # NEW
└── vm/
    ├── login.vm.dart
    └── register.vm.dart      # NEW
```

### Step 2: Create Models (`register.models.dart`)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register.models.freezed.dart';
part 'register.models.g.dart';

// Request Model
@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

// Response Model
@freezed
abstract class RegisterResponse with _$RegisterResponse {
  const factory RegisterResponse({
    required String status,
    required String message,
    required String token,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}
```

### Step 3: Create ViewModel (`register.vm.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/token_storage_service.dart';
import 'package:sales_sphere/core/constants/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/register.models.dart';

part 'register.vm.g.dart';

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  Future<RegisterResponse?> build() async {
    return null;
  }

  /// Validate name locally
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Validate email locally
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validate password locally
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Validate phone locally
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    if (value.length < 10) return 'Enter a valid phone number';
    return null;
  }

  /// Register method
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // Reset state
    state = const AsyncData(null);

    // Pre-validate
    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final phoneError = validatePhone(phone);

    if (nameError != null || emailError != null || passwordError != null || phoneError != null) {
      state = AsyncError({
        'name': nameError,
        'email': emailError,
        'password': passwordError,
        'phone': phoneError,
      }, StackTrace.empty);
      return;
    }

    // Begin async registration
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);
      final tokenStorage = ref.read(tokenStorageServiceProvider);

      AppLogger.i('🔐 Attempting registration for: $email');

      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerResponse = RegisterResponse.fromJson(response.data);

        AppLogger.i('✅ Registration successful');

        // Save token
        await tokenStorage.saveToken(registerResponse.token);

        // Save success state
        state = AsyncData(registerResponse);
      } else {
        state = AsyncError({
          'general': 'Registration failed. Please try again.',
        }, StackTrace.empty);
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Registration failed', e);

      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid request';
        state = AsyncError({'general': message}, StackTrace.empty);
      } else if (e.response?.statusCode == 409) {
        state = AsyncError({
          'general': 'Email already exists',
        }, StackTrace.empty);
      } else {
        state = AsyncError({
          'general': 'Network error. Please check your connection.',
        }, StackTrace.empty);
      }
    } catch (e, stack) {
      AppLogger.e('❌ Unexpected error during registration', e, stack);
      state = AsyncError({
        'general': 'Something went wrong. Please try again.',
      }, StackTrace.current);
    }
  }
}
```

### Step 4: Create View (`register_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import '../vm/register.vm.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final vm = ref.read(registerViewModelProvider.notifier);
      await vm.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // Re-validate to show errors
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(registerViewModelProvider.notifier);
    final registerState = ref.watch(registerViewModelProvider);

    final isLoading = registerState is AsyncLoading;

    // Navigate on success
    ref.listen(registerViewModelProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        context.go('/home');
      }
    });

    // Extract errors
    Map<String, String>? fieldErrors;
    String? generalError;

    if (registerState is AsyncError) {
      if (registerState.error is Map<String, String>) {
        fieldErrors = registerState.error as Map<String, String>;
        generalError = fieldErrors['general'];
      } else {
        generalError = registerState.error.toString();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'Create Account',
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
                    'Join SalesSphere',
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
                    "Create your account to get started",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // General Error
                  if (generalError != null) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        generalError,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Name Field
                  PrimaryTextField(
                    hintText: "Full Name",
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    hasFocusBorder: true,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (fieldErrors?.containsKey('name') ?? false) {
                        return fieldErrors!['name'];
                      }
                      return vm.validateName(value);
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Email Field
                  PrimaryTextField(
                    hintText: "Email Address",
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    hasFocusBorder: true,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (fieldErrors?.containsKey('email') ?? false) {
                        return fieldErrors!['email'];
                      }
                      return vm.validateEmail(value);
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Phone Field
                  PrimaryTextField(
                    hintText: "Phone Number",
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    hasFocusBorder: true,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (fieldErrors?.containsKey('phone') ?? false) {
                        return fieldErrors!['phone'];
                      }
                      return vm.validatePhone(value);
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Password Field
                  PrimaryTextField(
                    hintText: "Password",
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    hasFocusBorder: true,
                    enabled: !isLoading,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => isLoading ? null : _handleRegister(),
                    suffixWidget: IconButton(
                      onPressed: isLoading ? null : _togglePasswordVisibility,
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (fieldErrors?.containsKey('password') ?? false) {
                        return fieldErrors!['password'];
                      }
                      return vm.validatePassword(value);
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Register Button
                  PrimaryButton(
                    label: 'Create Account',
                    onPressed: _handleRegister,
                    isLoading: isLoading,
                    size: ButtonSize.medium,
                  ),

                  SizedBox(height: 24.h),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () => context.go('/'),
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
                            fontFamily: 'Poppins',
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

### Step 5: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `register.models.freezed.dart`
- `register.models.g.dart`
- `register.vm.g.dart`

### Step 6: Add Route

Edit `lib/core/router/route_handler.dart`:

```dart
// 1. Import the screen
import 'package:sales_sphere/features/auth/views/register_screen.dart';

// 2. Add to redirect logic (if public route)
final isGoingToRegister = requestedPath == '/register';

if (!isLoggedIn &&
    !isGoingToLogin &&
    !isGoingToRegister &&  // Add this
    !isGoingToForgotPassword &&
    // ...other routes
) {
  return '/';
}

// 3. Add route definition
GoRoute(
  path: '/register',
  name: 'register',
  builder: (context, state) => const RegisterScreen(),
),
```

### Step 7: Add Navigation to Register

In `login_screen.dart`, add:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      "Don't have an account? ",
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 14.sp,
      ),
    ),
    TextButton(
      onPressed: () => context.go('/register'),
      child: Text(
        'Sign Up',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
)
```

### Step 8: Test!

```bash
flutter run
```

---

## Pattern Templates

### Template 1: Simple Display Page (No API)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MySimplePage extends ConsumerWidget {
  const MySimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Title'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/previous-route'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Text('Content here'),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Template 2: Form Page (No API, Local State)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';

class MyFormPage extends ConsumerStatefulWidget {
  const MyFormPage({super.key});

  @override
  ConsumerState<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends ConsumerState<MyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle form submission
    }
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
          title: Text('Form Page'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  PrimaryTextField(
                    hintText: "Enter text",
                    controller: _controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    label: 'Submit',
                    onPressed: _handleSubmit,
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

### Template 3: Page with API (Full CRUD)

Use the Registration page example above as a template.

---

## Common Page Types

### 1. List Page

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      title: Text(item.name),
      onTap: () => context.go('/detail/\${item.id}'),
    );
  },
)
```

### 2. Detail Page

```dart
class DetailPage extends ConsumerWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail')),
      body: Center(child: Text('Detail for ID: $id')),
    );
  }
}
```

### 3. Settings Page

```dart
ListView(
  children: [
    SettingsTile(
      icon: Icons.person,
      title: 'Profile',
      onTap: () => context.go('/profile'),
    ),
    SettingsTile(
      icon: Icons.lock,
      title: 'Privacy',
      onTap: () => context.go('/privacy'),
    ),
  ],
)
```

---

## Checklist for Production-Ready Page

- [ ] Handles loading states
- [ ] Handles error states
- [ ] Form validation (if applicable)
- [ ] Hardware back button handling
- [ ] Keyboard-aware scrolling
- [ ] Responsive sizing (`.w`, `.h`, `.sp`)
- [ ] Proper navigation
- [ ] Code generation run
- [ ] Tested on device

---

## Next Steps

- **Code Examples**: See `CODE_EXAMPLES.md` for more snippets
- **Theming**: See `THEMING_AND_STYLING.md` for styling guidelines
- **Components**: See `REUSABLE_COMPONENTS.md` for available widgets
