import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'package:sales_sphere/features/leave/vm/edit_leave.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_dropdown_textfield.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EditLeaveScreen extends ConsumerStatefulWidget {
  final String leaveId;

  const EditLeaveScreen({super.key, required this.leaveId});

  @override
  ConsumerState<EditLeaveScreen> createState() => _EditLeaveScreenState();
}

class _EditLeaveScreenState extends ConsumerState<EditLeaveScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _reasonController;
  LeaveCategory? _selectedCategory;

  bool _isInitialized = false;
  bool _isEditMode = false;
  LeaveListItem? _currentLeave;

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

  void _initializeForm(LeaveListItem leaveItem) {
    if (_isInitialized) return;

    _currentLeave = leaveItem;
    _selectedCategory = LeaveCategory.fromValue(leaveItem.leaveType);
    _startDateController.text = _formatDisplayDate(leaveItem.startDate);
    _endDateController.text = _formatDisplayDate(leaveItem.endDate);
    _reasonController.text = leaveItem.reason ?? '';

    // Only allow edit mode for pending leaves
    if (leaveItem.status.toLowerCase() != 'pending') {
      _isEditMode = false;
    }

    _isInitialized = true;
  }

  bool get _canEditLeave {
    return _currentLeave?.status.toLowerCase() == 'pending';
  }

  void _toggleEditMode() {
    if (!_canEditLeave) return;
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDisplayDate(String utcDate) {
    try {
      final date = DateTime.parse(utcDate).toLocal();
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return utcDate;
    }
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
        await ref
            .read(editLeaveViewModelProvider(widget.leaveId).notifier)
            .updateLeave(
              leaveId: widget.leaveId,
              category: _selectedCategory!.value,
              startDate: _convertDateFormat(_startDateController.text)!,
              endDate: _convertDateFormat(_endDateController.text),
              reason: _reasonController.text.trim(),
            );

        if (!mounted) return;

        final submissionState = ref.read(
          editLeaveViewModelProvider(widget.leaveId),
        );
        submissionState.whenData((updatedLeave) {
          if (updatedLeave != null) {
            setState(() {
              _isEditMode = false;
              _currentLeave = updatedLeave;
              _initializeForm(updatedLeave);
            });
          }
        });

        if (!submissionState.hasError) {
          SnackbarUtils.showSuccess(context, 'Leave Updated Successfully');
        } else {
          final error = submissionState.error.toString();
          SnackbarUtils.showError(
            context,
            error.replaceFirst('Exception: ', ''),
          );
        }
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(editLeaveViewModelProvider(widget.leaveId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  if (_currentLeave != null) {
                    _initializeForm(_currentLeave!);
                  }
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: leaveAsync.when(
        data: (leaveItem) {
          if (leaveItem == null) {
            return Center(
              child: Text(
                'Leave not found',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }

          _initializeForm(leaveItem);

          return _buildForm(leaveItem);
        },
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.white),
              SizedBox(height: 16.h),
              Text(
                'Error: $error',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(editLeaveViewModelProvider(widget.leaveId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/corner_bubble.svg',
            fit: BoxFit.cover,
            height: 180.h,
          ),
        ),
        Column(
          children: [
            Container(height: 120.h, color: Colors.transparent),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: [
                        Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(LeaveListItem leaveItem) {
    final status = leaveItem.status.toLowerCase();
    final bool isPending = status == 'pending';
    final bool isEditable = isPending && _isEditMode;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 180.h,
            ),
          ),
          Column(
            children: [
              Container(height: 120.h, color: Colors.transparent),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        _buildStatusCard(leaveItem.status),
                        SizedBox(height: 16.h),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                CustomDatePicker(
                                  controller: _startDateController,
                                  hintText: "Start Date",
                                  prefixIcon: Icons.calendar_today_outlined,
                                  enabled: isEditable,
                                  firstDate: DateTime.now(),
                                ),
                                SizedBox(height: 16.h),

                                CustomDatePicker(
                                  controller: _endDateController,
                                  hintText: "End Date (Optional)",
                                  prefixIcon: Icons.calendar_today_outlined,
                                  enabled: isEditable,
                                  firstDate:
                                      _startDateController.text.isNotEmpty
                                      ? DateFormat(
                                          'dd MMM yyyy',
                                        ).parse(_startDateController.text)
                                      : DateTime.now(),
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        _startDateController.text.isNotEmpty) {
                                      try {
                                        final startDate = DateFormat(
                                          'dd MMM yyyy',
                                        ).parse(_startDateController.text);
                                        final endDate = DateFormat(
                                          'dd MMM yyyy',
                                        ).parse(value);
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
                                  enabled: isEditable,
                                  prefixIcon: Icons.label_outline,
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
                                  label: const Text("Reason"),
                                  hintText: "Enter reason for leave",
                                  prefixIcon: Icons.description_outlined,
                                  hasFocusBorder: true,
                                  enabled: isEditable,
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Button - only show for pending leaves
              if (isPending)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    MediaQuery.of(context).padding.bottom + 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _isEditMode
                      ? PrimaryButton(
                          label: "Save Changes",
                          onPressed: _handleSubmit,
                          leadingIcon: Icons.check_rounded,
                          size: ButtonSize.medium,
                        )
                      : PrimaryButton(
                          label: "Edit Detail",
                          onPressed: _toggleEditMode,
                          leadingIcon: Icons.edit_outlined,
                          size: ButtonSize.medium,
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS CARD WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildStatusCard(String status) {
    // Define styles based on status
    Color bgColor;
    Color borderColor;
    Color textColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = const Color(0xFFE8F5E9); // Light Green
        borderColor = const Color(0xFFC8E6C9);
        textColor = const Color(0xFF2E7D32); // Dark Green
        displayStatus = 'Approved';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE); // Light Red
        borderColor = const Color(0xFFFFCDD2);
        textColor = const Color(0xFFC62828); // Dark Red
        displayStatus = 'Rejected';
        break;
      case 'pending':
      default:
        bgColor = const Color(0xFFFFF9E6); // Light Yellow (Cream)
        borderColor = const Color(0xFFFFECB3);
        textColor = const Color(0xFFB78628); // Gold/Brown
        displayStatus = 'Pending';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r), // Highly rounded
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The Dot
          Container(
            height: 10.w,
            width: 10.w,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 16.w),

          // The Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Leave Status",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Read Only Tag - only for non-pending
          if (status.toLowerCase() != 'pending')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Read Only",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: textColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
