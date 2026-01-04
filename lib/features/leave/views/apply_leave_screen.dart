import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_dropdown_textfield.dart';
import 'package:sales_sphere/features/leave/vm/apply_leave.vm.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';

class ApplyLeaveRequestScreen extends ConsumerStatefulWidget {
  const ApplyLeaveRequestScreen({super.key});

  @override
  ConsumerState<ApplyLeaveRequestScreen> createState() => _ApplyLeaveRequestScreenState();
}

class _ApplyLeaveRequestScreenState extends ConsumerState<ApplyLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _reasonController;
  LeaveCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _reasonController = TextEditingController();
    
    // Listen to start date changes to update end date picker constraints
    _startDateController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _convertDateFormat(String? displayDate) {
    if (displayDate == null || displayDate.isEmpty) return null;
    try {
      final date = DateFormat('dd MMM yyyy').parse(displayDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      AppLogger.e('Date conversion error: $e');
      return displayDate;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        SnackbarUtils.showWarning(context, 'Please select a Category');
        return;
      }

      try {
        await ref.read(applyLeaveViewModelProvider.notifier).submitLeave(
          category: _selectedCategory!.value,
          startDate: _convertDateFormat(_startDateController.text)!,
          endDate: _convertDateFormat(_endDateController.text),
          reason: _reasonController.text.trim(),
        );

        if (!mounted) return;

        SnackbarUtils.showSuccess(context, 'Leave Requested Successfully');
        context.pop();
      } catch (e) {
        if (!mounted) return;
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        SnackbarUtils.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Apply Leave Request",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDatePicker(
                          controller: _startDateController,
                          hintText: "Start Date",
                          prefixIcon: Icons.calendar_today_outlined,
                          enabled: true,
                          firstDate: DateTime.now(),
                        ),
                        SizedBox(height: 16.h),

                        CustomDatePicker(
                          controller: _endDateController,
                          hintText: "End Date (Optional)",
                          prefixIcon: Icons.calendar_today_outlined,
                          enabled: true,
                          firstDate: _startDateController.text.isNotEmpty
                              ? DateFormat('dd MMM yyyy').parse(_startDateController.text)
                              : DateTime.now(),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && _startDateController.text.isNotEmpty) {
                              try {
                                final startDate = DateFormat('dd MMM yyyy').parse(_startDateController.text);
                                final endDate = DateFormat('dd MMM yyyy').parse(value);
                                if (endDate.isBefore(startDate)) {
                                  return 'End date cannot be before start date';
                                }
                              } catch (e) {
                                return null;
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        CustomDropdownTextField<LeaveCategory>(
                          hintText: "Category",
                          value: _selectedCategory,
                          enabled: true,
                          items: LeaveCategory.values.map((category) {
                            return DropdownItem<LeaveCategory>(
                              value: category,
                              label: category.displayName,
                              icon: category.icon,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        PrimaryTextField(
                          controller: _reasonController,
                          hintText: "Reason",
                          prefixIcon: Icons.description_outlined,
                          hasFocusBorder: true,
                          minLines: 1,
                          maxLines: 5,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please provide a reason';
                            }
                            if (v.trim().length < 3) {
                              return 'Reason must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100.h : 80.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                MediaQuery.of(context).padding.bottom + 16.h,
              ),
              color: Colors.white,
              child: PrimaryButton(
                label: "Submit Leave Request",
                onPressed: _handleSubmit,
                size: ButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}