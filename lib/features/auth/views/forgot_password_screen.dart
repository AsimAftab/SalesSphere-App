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
      // For now, simulate email check (randomly for demo)
      // In production, this will call the backend API
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate checking if email is registered
      // Replace this with actual backend call
      final isEmailRegistered = _checkEmailRegistered(_emailController.text);

      if (isEmailRegistered) {
        _showSuccessBottomSheet();
      } else {
        _showErrorBottomSheet();
      }
    }
  }

  // TODO: Replace with actual backend API call
  bool _checkEmailRegistered(String email) {
    // Mock registered emails for testing UI
    // In production, this will be an API call
    final registeredEmails = [
      'asimaftab303@gmail.com',
      'test@gmail.com',
    ];

    return registeredEmails.contains(email.toLowerCase());
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40.sp,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              'Email Sent!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              'A password reset link has been sent to your email address. Please check your inbox.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            SizedBox(height: 28.h),

            // Continue Button
            PrimaryButton(
              label: 'Back to Login',
              onPressed: () {
                Navigator.of(context).pop(); // Close bottom sheet
                context.go('/'); // Navigate to login
              },
              size: ButtonSize.medium,
            ),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _showErrorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40.sp,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              'Email Not Registered',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              'This email address is not registered with us. Please check the email address or sign up for a new account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            SizedBox(height: 28.h),

            // Try Again Button
            PrimaryButton(
              label: 'Try Again',
              onPressed: () {
                Navigator.of(context).pop(); // Close bottom sheet
              },
              size: ButtonSize.medium,
            ),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background Gradient
            Container(
              width: double.infinity,
              height: double.infinity,
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
            ),

            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),

                    // Illustration
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/forgot_password.svg',
                        height: 250.h,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Spacer
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),

            // Forgot Password Card (Bottom Sheet Style)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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

                        // Title
                        Text(
                          'Forgot Password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Description
                        Text(
                          "Enter your email to receive a password reset link.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 36.h),

                        // Email Field
                        PrimaryTextField(
                          hintText: "Email Address",
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          hasFocusBorder: true,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSubmit(),
                          validator: (value) {
                            return FieldValidators.validateEmail(value);
                          },
                        ),

                        SizedBox(height: 28.h),

                        // Submit Button
                        PrimaryButton(
                          label: 'Send Reset Link',
                          onPressed: _handleSubmit,
                          size: ButtonSize.large,
                        ),

                        SizedBox(height: 20.h),

                        // Back to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remember your password? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15.sp,
                                fontFamily: 'Poppins',
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
                                  fontSize: 15.sp,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.secondary,
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

            // Back Button (Positioned on top of everything)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, top: 8.h),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => context.go('/'),
                  ),
                ),
              ),
            ),>>>>>>> c0542cd35114e3945b15a3e49de2f65f863614e0
          ],
        ),
      ),
    );
  }
}
