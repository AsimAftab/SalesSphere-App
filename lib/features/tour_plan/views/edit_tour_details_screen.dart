import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/edit_tour.model.dart';
import '../vm/edit_tour.vm.dart';

class EditTourDetailsScreen extends ConsumerStatefulWidget {
  final String tourId;

  const EditTourDetailsScreen({
    super.key,
    required this.tourId,
  });

  @override
  ConsumerState<EditTourDetailsScreen> createState() => _EditTourDetailsScreenState();
}

class _EditTourDetailsScreenState extends ConsumerState<EditTourDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  bool _isDataLoaded = false;

  // Controllers
  late TextEditingController _placeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _purposeController;

  TourDetails? _currentTour;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _placeController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _purposeController = TextEditingController();
  }

  void _populateFields(TourDetails tour) {
    _currentTour = tour;
    _placeController.text = tour.placeOfVisit;
    _startDateController.text = tour.startDate;
    _endDateController.text = tour.endDate;
    _purposeController.text = tour.purposeOfVisit;
  }

  @override
  void dispose() {
    _placeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updated = _currentTour!.copyWith(
          placeOfVisit: _placeController.text.trim(),
          startDate: _startDateController.text.trim(),
          endDate: _endDateController.text.trim(),
          purposeOfVisit: _purposeController.text.trim(),
        );

        await ref.read(editTourViewModelProvider.notifier).updateTour(updated);

        setState(() => _isEditMode = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tour plan updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));

    // Listen for data to populate fields once
    ref.listen(tourByIdProvider(widget.tourId), (prev, next) {
      if (next is AsyncData<TourDetails?> && next.value != null && !_isDataLoaded) {
        _populateFields(next.value!);
        _isDataLoaded = true;
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
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
                  if (_currentTour != null) _populateFields(_currentTour!);
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
      body: Stack(
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
          tourAsync.when(
            data: (tour) => tour == null
                ? const Center(child: Text("Tour not found"))
                : _buildContent(tour),
            loading: () => Skeletonizer(enabled: true, child: _buildContent(null)),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TourDetails? tour) {
    final bool isPending = (tour?.status.toLowerCase() ?? 'pending') == 'pending';
    final bool isEditable = _isEditMode && isPending;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Padding(
              padding: EdgeInsets.only(top: 100.h, bottom: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Status Card matching Expenses UI
                    if (tour != null) _buildStatusCard(tour.status),
                    SizedBox(height: 24.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PrimaryTextField(
                            hintText: "Place of visit",
                            controller: _placeController,
                            prefixIcon: Icons.location_on_outlined,
                            enabled: isEditable,
                            hasFocusBorder: true,
                          ),
                          SizedBox(height: 16.h),
                          CustomDatePicker(
                            hintText: "Start Date",
                            controller: _startDateController,
                            prefixIcon: Icons.calendar_today_outlined,
                            enabled: isEditable,
                          ),
                          SizedBox(height: 16.h),
                          CustomDatePicker(
                            hintText: "End Date",
                            controller: _endDateController,
                            prefixIcon: Icons.calendar_today_outlined,
                            enabled: isEditable,
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            hintText: "Purpose of the visit",
                            controller: _purposeController,
                            prefixIcon: Icons.description_outlined,
                            enabled: isEditable,
                            minLines: 1,
                            maxLines: 5,
                            hasFocusBorder: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom Action Bar
        if (isPending)
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: PrimaryButton(
              label: _isEditMode ? 'Save Changes' : 'Edit Detail',
              onPressed: _isEditMode ? _handleSave : _toggleEditMode,
              leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
              size: ButtonSize.medium,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(String status) {
    Color textColor = const Color(0xFFB78628); // Default Pending Gold
    Color bgColor = const Color(0xFFFFF9E6);
    Color borderColor = const Color(0xFFFFECB3);

    if (status.toLowerCase() == 'approved') {
      textColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFFC8E6C9);
    } else if (status.toLowerCase() == 'rejected') {
      textColor = const Color(0xFFC62828);
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFFFCDD2);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 10.w,
            width: 10.w,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tour Plan Status",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 16.sp, color: textColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (status.toLowerCase() != 'pending')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(8.r)),
              child: Text("Read Only", style: TextStyle(fontSize: 10.sp, color: textColor.withOpacity(0.7))),
            ),
        ],
      ),
    );
  }
}