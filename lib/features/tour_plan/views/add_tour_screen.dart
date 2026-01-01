import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import '../models/add_tour.models.dart';
import '../vm/add_tour.vm.dart';

class AddTourPlanScreen extends ConsumerStatefulWidget {
  const AddTourPlanScreen({super.key});

  @override
  ConsumerState<AddTourPlanScreen> createState() => _AddTourPlanScreenState();
}

class _AddTourPlanScreenState extends ConsumerState<AddTourPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _placeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  void dispose() {
    _placeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateTourRequest(
        placeOfVisit: _placeController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        purposeOfVisit: _purposeController.text.trim(),
      );

      final success = await ref
          .read(addTourViewModelProvider.notifier)
          .saveTourPlanLocally(request);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tour Plan saved locally (Frontend only)'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C435D), // Match the dark blue in your image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Add Tour Plan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
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
                    children: [
                      PrimaryTextField(
                        hintText: "Place of visit",
                        controller: _placeController,
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) => ref
                            .read(addTourViewModelProvider.notifier)
                            .validateRequired(v, "Place"),
                      ),
                      SizedBox(height: 16.h),
                      CustomDatePicker(
                        hintText: "Start Date",
                        controller: _startDateController,
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                      SizedBox(height: 16.h),
                      CustomDatePicker(
                        hintText: "End Date",
                        controller: _endDateController,
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                      SizedBox(height: 16.h),
                      PrimaryTextField(
                        hintText: "Purpose of the visit",
                        controller: _purposeController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline, 
                      ),
                      SizedBox(height: 60.h),
                      PrimaryButton(
                        label: 'Add Tour Plan',
                        onPressed: _handleSave,
                        width: double.infinity,
                        size: ButtonSize.medium,
                      ),
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