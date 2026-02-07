import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

/// Custom Date Picker Field that matches PrimaryTextField style
class CustomDatePicker extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime)? selectableDayPredicate;

  const CustomDatePicker({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? DateTime(2100);

    // Ensure initialDate is not before firstDate
    DateTime effectiveInitialDate = initialDate ?? now;
    if (effectiveInitialDate.isBefore(effectiveFirstDate)) {
      effectiveInitialDate = effectiveFirstDate;
    }
    if (effectiveInitialDate.isAfter(effectiveLastDate)) {
      effectiveInitialDate = effectiveLastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ensureSelectableInitialDate(
        effectiveInitialDate,
        effectiveFirstDate,
        effectiveLastDate,
      ),
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      selectableDayPredicate: selectableDayPredicate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textdark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  DateTime _ensureSelectableInitialDate(
    DateTime initial,
    DateTime first,
    DateTime last,
  ) {
    if (selectableDayPredicate == null) {
      return initial;
    }

    if (selectableDayPredicate!(initial)) {
      return initial;
    }

    // Find the next selectable date within range
    DateTime current = initial.isBefore(first) ? first : initial;
    if (current.isAfter(last)) {
      current = last;
    }

    while (!current.isAfter(last)) {
      if (selectableDayPredicate!(current)) {
        return current;
      }
      current = current.add(const Duration(days: 1));
    }

    // Fallback to first date if no selectable date found
    return first;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      style: TextStyle(
        fontSize: 15.sp,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: enabled
            ? AppColors.textPrimary
            : AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Poppins',
          color: enabled
              ? AppColors.textHint
              : AppColors.textHint.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: enabled ? AppColors.primary : Colors.grey.shade400,
                size: 20.sp,
              )
            : null,
        suffixIcon: enabled
            ? Icon(Icons.calendar_today, color: AppColors.primary, size: 18.sp)
            : null,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0), // Colors.grey.shade300
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0), // Colors.grey.shade300
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        errorStyle: TextStyle(
          fontSize: 12.sp,
          fontFamily: 'Poppins',
          color: AppColors.error,
        ),
      ),
      validator: validator,
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }
}
