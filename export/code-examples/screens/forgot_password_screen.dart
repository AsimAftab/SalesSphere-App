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
      // For now, just show success dialog
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
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            const Text('Email Sent'),
          ],
        ),
        content: Text(
          'A password reset link has been sent to your email address. Please check your inbox.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/'); // Navigate to login
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
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                Colors.white,
                Colors.white,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative Corner Bubble - Top Right
              Positioned(
                top: -50.h,
                right: -50.w,
                child: SvgPicture.asset(
                  'assets/images/right_bubble.svg',
                  height: 250.h,
                  width: 200.w,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary.withValues(alpha: 0.08),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Decorative Bubble - Bottom Left
              Positioned(
                bottom: -30.h,
                left: -40.w,
                child: SvgPicture.asset(
                  'assets/images/left_bubble.svg',
                  height: 200.h,
                  width: 150.w,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    AppColors.secondary.withValues(alpha: 0.06),
                    BlendMode.srcIn,
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          onPressed: () => context.go('/'),
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Logo
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 80.h,
                        width: 80.w,
                      ),

                      SizedBox(height: 20.h),

                      // Sales Sphere Text
                      Text(
                        'Sales Sphere',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Card Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              spreadRadius: 0,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Icon
                              Container(
                                width: 60.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Title
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              // Description
                              Text(
                                "Don't worry! It happens. Enter your email address and we'll send you a link to reset your password.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(height: 28.h),

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

                              SizedBox(height: 24.h),

                              // Submit Button
                              PrimaryButton(
                                label: 'Send Reset Link',
                                onPressed: _handleSubmit,
                                size: ButtonSize.medium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14.sp,
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
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}
