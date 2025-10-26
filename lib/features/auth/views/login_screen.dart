import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    }
  }

  void _forgotPassword() {
    Navigator.pushNamed(context, '/forgot-password'); // Update with your route
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup'); // Update with your route
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final vm = ref.read(loginViewModelProvider.notifier);
    final loginState = ref.watch(loginViewModelProvider);

    final isLoading = loginState is AsyncLoading;

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
      body: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Header Stack ---
              SizedBox(
                width: 1.sw,
                height: 280.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      height: 280.h,
                      width: 240.w,
                      child: SvgPicture.asset(
                        'assets/images/login_left.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      height: 280.h,
                      width: 160.w,
                      child: SvgPicture.asset(
                        'assets/images/login_right.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 20.h,
                      right: -120.w,
                      height: 300.h,
                      width: 500.w,
                      child: SvgPicture.asset('assets/images/logo.svg'),
                    ),
                    Positioned(
                      top: 150.h,
                      left: 40.w,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                "Hi, Welcome Back!👋",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),

              // --- General error message ---
              if (generalError != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text(
                    generalError,
                    style: TextStyle(color: colorScheme.error, fontSize: 14.sp),
                  ),
                ),
              SizedBox(height: 20.h),

              // --- Email Field ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: "Email Address",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    // Inline backend error first, then local validation
                    if (fieldErrors?.containsKey('email') ?? false) {
                      return fieldErrors!['email'];
                    }
                    return vm.validateEmailLocally(value);
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(height: 20.h),

              // --- Password Field ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off_sharp),
                      onPressed: isLoading ? null : _togglePasswordVisibility,
                    ),
                  ),
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (fieldErrors?.containsKey('password') ?? false) {
                      return fieldErrors!['password'];
                    }
                    return vm.validatePasswordLocally(value);
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => isLoading ? null : _handleLogin(vm),
                ),
              ),
              SizedBox(height: 8.h),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: TextButton(
                    onPressed: isLoading ? null : _forgotPassword,
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: const Color(0xFF37AFFA),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // --- Login Button ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleLogin(vm),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h)),
                  child: isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Login'),
                ),
              ),
              SizedBox(height: 40.h),

              // --- Sign Up Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Do not have an Account? ',
                      style: TextStyle(fontSize: 14.sp)),
                  TextButton(
                    onPressed: isLoading ? null : _navigateToSignUp,
                    child: Text(
                      "Signup",
                      style: TextStyle(
                        color: const Color(0xFF37AFFA),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
