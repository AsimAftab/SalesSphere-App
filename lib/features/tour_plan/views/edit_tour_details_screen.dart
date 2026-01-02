import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/tour_plan.model.dart';
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

  late TextEditingController _placeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _purposeController;

  TourDetails? _currentTour;
  DateTime? _selectedStartDate;

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
    _startDateController.addListener(_onStartDateChanged);
  }

  void _onStartDateChanged() {
    if (_startDateController.text.isNotEmpty) {
      final parsed = _parseDisplayDate(_startDateController.text);
      if (parsed != null && parsed != _selectedStartDate) {
        setState(() {
          _selectedStartDate = parsed;
        });
        if (_endDateController.text.isNotEmpty) {
          final endDate = _parseDisplayDate(_endDateController.text);
          if (endDate != null && endDate.isBefore(parsed)) {
            _endDateController.clear();
          }
        }
      }
    }
  }

  DateTime? _parseDisplayDate(String text) {
    try {
      return DateFormat('dd MMM yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseApiDate(String text) {
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  String _toDisplayFormat(String apiDate) {
    final parsed = _parseApiDate(apiDate);
    if (parsed == null) return apiDate;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  String _toApiDateFormat(String displayDate) {
    final parsed = _parseDisplayDate(displayDate);
    if (parsed == null) return displayDate;
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  void _populateFields(TourDetails tour) {
    _currentTour = tour;
    _placeController.text = tour.placeOfVisit;
    _startDateController.text = _toDisplayFormat(tour.startDate);
    _endDateController.text = _toDisplayFormat(tour.endDate);
    _purposeController.text = tour.purposeOfVisit;

    final startParsed = _parseApiDate(tour.startDate);
    if (startParsed != null) {
      _selectedStartDate = startParsed;
    }
  }

  @override
  void dispose() {
    _startDateController.removeListener(_onStartDateChanged);
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

  String? _validateStartDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Start date is required';
    }
    return null;
  }

  String? _validateEndDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'End date is required';
    }
    if (_startDateController.text.isNotEmpty) {
      final startDate = _parseDisplayDate(_startDateController.text);
      final endDate = _parseDisplayDate(value);
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        return 'End date must be on or after start date';
      }
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = UpdateTourRequest(
        placeOfVisit: _placeController.text.trim(),
        startDate: _toApiDateFormat(_startDateController.text.trim()),
        endDate: _toApiDateFormat(_endDateController.text.trim()),
        purposeOfVisit: _purposeController.text.trim(),
      );

      final success = await ref.read(editTourViewModelProvider.notifier).updateTourPlan(
            tourId: widget.tourId,
            request: request,
          );

      if (mounted) {
        if (success) {
          setState(() => _isEditMode = false);
          ref.invalidate(tourByIdProvider(widget.tourId));
          SnackbarUtils.showSuccess(context, 'Tour plan updated successfully');
        } else {
          final state = ref.read(editTourViewModelProvider);
          final errorMessage = state.hasError
              ? state.error.toString().replaceAll('Exception: ', '')
              : 'Failed to update tour plan';
          SnackbarUtils.showError(context, errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));
    final editState = ref.watch(editTourViewModelProvider);
    final isLoading = editState.isLoading;

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
              onPressed: isLoading
                  ? null
                  : () {
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
                : _buildContent(tour, isLoading),
            loading: () => Skeletonizer(enabled: true, child: _buildContent(null, false)),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TourDetails? tour, bool isLoading) {
    final bool isPending = (tour?.status.toLowerCase() ?? 'pending') == 'pending';
    final bool isEditable = _isEditMode && isPending && !isLoading;

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
                            color: Colors.black.withValues(alpha: 0.04),
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
                            validator: isEditable
                                ? (v) => ref.read(editTourViewModelProvider.notifier).validateRequired(v, "Place")
                                : null,
                          ),
                          SizedBox(height: 16.h),
                          CustomDatePicker(
                            hintText: "Start Date",
                            controller: _startDateController,
                            prefixIcon: Icons.calendar_today_outlined,
                            enabled: isEditable,
                            firstDate: DateTime.now(),
                            validator: isEditable ? _validateStartDate : null,
                          ),
                          SizedBox(height: 16.h),
                          CustomDatePicker(
                            hintText: "End Date",
                            controller: _endDateController,
                            prefixIcon: Icons.calendar_today_outlined,
                            enabled: isEditable,
                            firstDate: _selectedStartDate ?? DateTime.now(),
                            validator: isEditable ? _validateEndDate : null,
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
        if (isPending)
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
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
            child: PrimaryButton(
              label: _isEditMode ? 'Save Changes' : 'Edit Detail',
              onPressed: isLoading ? null : (_isEditMode ? _handleSave : _toggleEditMode),
              leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
              size: ButtonSize.medium,
              isLoading: isLoading,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(String status) {
    Color textColor = const Color(0xFFB78628);
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
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8.r)),
              child: Text("Read Only", style: TextStyle(fontSize: 10.sp, color: textColor.withValues(alpha: 0.7))),
            ),
        ],
      ),
    );
  }
}
