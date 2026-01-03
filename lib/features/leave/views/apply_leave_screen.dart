import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/features/leave/vm/apply_leave.vm.dart';

class ApplyLeaveRequestScreen extends ConsumerStatefulWidget {
  const ApplyLeaveRequestScreen({super.key});

  @override
  ConsumerState<ApplyLeaveRequestScreen> createState() => _ApplyLeaveRequestScreenState();
}

class _ApplyLeaveRequestScreenState extends ConsumerState<ApplyLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final LayerLink _categoryLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _reasonController;
  String? _selectedCategory;

  // Track dropdown state for UI changes
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _hideDropdown();
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _hideDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      // Revert icon and border state
      setState(() => _isDropdownOpen = false);
    }
  }

  // Professional icons for each category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sick Leave': return Icons.medical_services_outlined;
      case 'Maternity Leave': return Icons.child_care_outlined;
      case 'Paternity Leave': return Icons.face_outlined;
      case 'Family Responsibility Leave': return Icons.family_restroom_outlined;
      case 'Compassionate Leave': return Icons.volunteer_activism_outlined;
      case 'Leave for religious holidays': return Icons.church_outlined;
      default: return Icons.more_horiz_outlined;
    }
  }

  void _showCategoryDropdown() {
    _hideDropdown();
    setState(() => _isDropdownOpen = true);

    final List<String> categories = [
      'Sick Leave',
      'Maternity Leave',
      'Paternity Leave',
      'Family Responsibility Leave',
      'Compassionate Leave',
      'Leave for religious holidays',
      'Miscellaneous/Others'
    ];

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width - 48.w,
            child: CompositedTransformFollower(
              link: _categoryLink,
              showWhenUnlinked: false,
              offset: Offset(0, 62.h),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 350.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade50),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategory == category;

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _getCategoryIcon(category),
                          color: Colors.grey.shade600,
                          size: 20.sp,
                        ),
                        title: Text(
                            category,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            )
                        ),
                        // ADDED TICK HERE
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.secondary, size: 20.sp)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _isDropdownOpen = false;
                          });
                          _hideDropdown();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Category'))
        );
        return;
      }

      final data = {
        'leaveType': _selectedCategory,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text.isEmpty
            ? _startDateController.text
            : _endDateController.text,
        'reason': _reasonController.text.trim(),
      };

      // 1. Call the submission
      await ref.read(applyLeaveViewModelProvider.notifier).submitLeave(data: data);

      // 2. CHECK MOUNTED: Ensure context is still valid after async gap
      if (!mounted) return;

      // 3. CHECK STATE: Only pop if there was no error
      final submissionState = ref.read(applyLeaveViewModelProvider);
      if (!submissionState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Leave Requested Successfully'),
                backgroundColor: Colors.green
            )
        );
        context.pop();
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
          _hideDropdown();
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
                        ),
                        SizedBox(height: 16.h),

                        CustomDatePicker(
                          controller: _endDateController,
                          hintText: "End Date (Optional)",
                          prefixIcon: Icons.calendar_today_outlined,
                          enabled: true,
                        ),
                        SizedBox(height: 16.h),

                        // UPDATED CATEGORY DROPDOWN
                        CompositedTransformTarget(
                          link: _categoryLink,
                          child: GestureDetector(
                            onTap: _showCategoryDropdown,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  // Border color changes based on open state
                                  border: Border.all(
                                    color: _isDropdownOpen ? AppColors.secondary : const Color(0xFFE0E0E0),
                                    width: _isDropdownOpen ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_offer_outlined, color: Colors.grey.shade600, size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Text(
                                    _selectedCategory ?? "Category",
                                    style: TextStyle(
                                        color: _selectedCategory != null ? AppColors.textPrimary : AppColors.textHint,
                                        fontFamily: 'Poppins',
                                        fontSize: 15.sp
                                    ),
                                  ),
                                  const Spacer(),
                                  // Arrow direction changes based on state
                                  Icon(
                                      _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade400
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        PrimaryTextField(
                          controller: _reasonController,
                          hintText: "Reason (Optional)",
                          prefixIcon: Icons.description_outlined,
                          hasFocusBorder: true,
                          minLines: 1,
                          maxLines: 5,
                          validator: (v) => null,
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