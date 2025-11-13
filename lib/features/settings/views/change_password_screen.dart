import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/features/settings/vm/change_password_vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleConfirmNewPasswordVisibility() {
    setState(() {
      _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
    });
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(changePasswordViewModelProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmNewPassword: _confirmNewPasswordController.text,
          );

      if (!mounted) return;

      if (success) {
        SnackbarUtils.showSuccess(
          context,
          'Password changed successfully! Please login again.',
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(changePasswordViewModelProvider).error;
        String errorMessage = 'Failed to change password';

        if (error is Map) {
          errorMessage = error['general'] ?? errorMessage;
        }

        SnackbarUtils.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordViewModelProvider);
    final isLoading = changePasswordState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Password
                    Text(
                      'Current Password',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    PrimaryTextField(
                      controller: _currentPasswordController,
                      hintText: 'Enter your current password',
                      obscureText: !_isCurrentPasswordVisible,
                      suffixWidget: IconButton(
                        onPressed: _toggleCurrentPasswordVisibility,
                        icon: Icon(
                          _isCurrentPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // New Password
                    Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    PrimaryTextField(
                      controller: _newPasswordController,
                      hintText: 'Enter your new password',
                      obscureText: !_isNewPasswordVisible,
                      suffixWidget: IconButton(
                        onPressed: _toggleNewPasswordVisibility,
                        icon: Icon(
                          _isNewPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                      ),
                      validator: ref.read(changePasswordViewModelProvider.notifier).validatePassword,
                    ),

                    SizedBox(height: 20.h),

                    // Confirm New Password
                    Text(
                      'Confirm New Password',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    PrimaryTextField(
                      controller: _confirmNewPasswordController,
                      hintText: 'Re-enter your new password',
                      obscureText: !_isConfirmNewPasswordVisible,
                      suffixWidget: IconButton(
                        onPressed: _toggleConfirmNewPasswordVisibility,
                        icon: Icon(
                          _isConfirmNewPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Password Requirements Info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18.sp, color: AppColors.info),
                      SizedBox(width: 8.w),
                      Text(
                        'Password Requirements',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildRequirement('At least 8 characters'),
                  _buildRequirement('One uppercase letter (A-Z)'),
                  _buildRequirement('One lowercase letter (a-z)'),
                  _buildRequirement('One number (0-9)'),
                  _buildRequirement('One special character (!@#\$%^&*)'),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
