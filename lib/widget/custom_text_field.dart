import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';

/// Primary Text Field Component
/// A beautiful, reusable text field with proper error handling
class PrimaryTextField extends StatefulWidget {
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final String hintText;
  final TextEditingController controller;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final List<String>? autofillHints;
  final bool hasFocusBorder;
  final String? errorText;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final int? minLines;
  final int? maxLines;

  const PrimaryTextField({
    super.key,
    this.prefixIcon,
    required this.hintText,
    required this.controller,
    this.suffixWidget,
    this.label,
    this.labelStyle,
    this.validator,
    this.obscureText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.autofillHints,
    this.hasFocusBorder = false,
    this.errorText,
    this.enabled,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.minLines,
    this.maxLines,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  String? _validatorError;

  @override
  Widget build(BuildContext context) {
    // Priority: errorText prop > validator error
    final displayError = widget.errorText ?? _validatorError;
    final hasError = displayError != null && displayError.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          obscureText: widget.obscureText ?? false,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          enabled: widget.enabled ?? true,
          textInputAction: widget.textInputAction,
          minLines: widget.minLines,
          maxLines: widget.obscureText == true ? 1 : (widget.maxLines ?? 1),
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: (value) {
            // Clear error on typing
            if (_validatorError != null) {
              setState(() {
                _validatorError = null;
              });
            }
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            hintText: widget.hintText,
            label: widget.label,
            labelStyle: widget.labelStyle ??
                TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                ),
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: hasError ? AppColors.error : AppColors.textSecondary,
                    size: 20.sp,
                  )
                : null,
            suffixIcon: widget.suffixWidget,
            filled: true,
            fillColor: hasError
                ? AppColors.error.withOpacity(0.05)
                : AppColors.surface,

            // Border Styles
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.secondary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.5),
                width: 1.5,
              ),
            ),

            // Hide default error text (we'll show custom one below)
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            errorMaxLines: 1,
          ),
          validator: (value) {
            if (widget.validator != null) {
              final error = widget.validator!(value);
              // Update state to show error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _validatorError != error) {
                  setState(() {
                    _validatorError = error;
                  });
                }
              });
              return error;
            }
            return null;
          },
        ),

        // Beautiful Error Message Display
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 16.w, right: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14.sp,
                  color: AppColors.error,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    displayError,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
