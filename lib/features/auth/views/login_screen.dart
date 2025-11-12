import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../vm/login.vm.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin(LoginViewModel vm) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      await vm.login(email, password);

      // Re-validate form to show server errors
      _formKey.currentState?.validate();
    }
  }

  void _forgotPassword() {
    context.go('/forgot-password');
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final vm = ref.read(loginViewModelProvider.notifier);
    final loginState = ref.watch(loginViewModelProvider);

    final isLoading = loginState is AsyncLoading;

    // Navigate to home on successful login
    ref.listen(loginViewModelProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        // Login successful, navigate to home
        context.go('/home');
      }
    });

    // Extract field errors and general error
    Map<String, String>? fieldErrors;
    String? generalError;

    if (loginState is AsyncError) {
      if (loginState.error is Map<String, String>) {
        fieldErrors = loginState.error as Map<String, String>;
        generalError = fieldErrors['general'];
      } else {
        generalError = loginState.error.toString();
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // --- Upper Portion with Logo, Branding & Bubbles ---
          Container(
            width: double.infinity,
            height: 500.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Left Bubble
                Positioned(
                  top: 0,
                  left: 0,
                  child: SvgPicture.asset(
                    'assets/images/left_bubble.svg',
                    height: 200.h,
                    width: 150.w,
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.1),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                // Right Bubble
                Positioned(
                  bottom: 50.h,
                  right: -30.w,
                  child: SvgPicture.asset(
                    'assets/images/right_bubble.svg',
                    height: 200.h,
                    width: 150.w,
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.1),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                // Center Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      // Logo
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 100.h,
                        width: 100.w,
                      ),
                      SizedBox(height: 16.h),
                      // Sales Sphere Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sales\n',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'Sphere',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Bottom White Card with Form ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Decorative handle
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // --- General Error Message ---
                      if (generalError != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  generalError,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // --- Email Field ---
                      PrimaryTextField(
                        hintText: "Email Address",
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          // Server error takes priority
                          if (fieldErrors?.containsKey('email') ?? false) {
                            return fieldErrors!['email'];
                          }
                          // Local validation
                          return FieldValidators.validateEmail(value);
                        },
                      ),

                      SizedBox(height: 16.h),

                      // --- Password Field ---
                      PrimaryTextField(
                        hintText: "Password",
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => isLoading ? null : _handleLogin(vm),
                        obscureText: !_isPasswordVisible,
                        suffixWidget: IconButton(
                          onPressed: isLoading ? null : _togglePasswordVisibility,
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          // Server error takes priority
                          if (fieldErrors?.containsKey('password') ?? false) {
                            return fieldErrors!['password'];
                          }
                          // Local validation
                          return vm.validatePasswordLocally(value);
                        },
                      ),

                      SizedBox(height: 12.h),

                      // --- Forgot Password ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : _forgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // --- Login Button ---
                      PrimaryButton(
                        label: 'Login',
                        onPressed: () => _handleLogin(vm),
                        isLoading: isLoading,
                        size: ButtonSize.medium,
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
