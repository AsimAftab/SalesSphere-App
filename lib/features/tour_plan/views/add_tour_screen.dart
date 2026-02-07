import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';

import '../models/tour_plan.model.dart';
import '../vm/add_tour.vm.dart';
import '../vm/tour_plan.vm.dart';

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

  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _startDateController.addListener(_onStartDateChanged);
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

  void _onStartDateChanged() {
    if (_startDateController.text.isNotEmpty) {
      final parsed = _parseDisplayDate(_startDateController.text);
      if (parsed != null && parsed != _selectedStartDate) {
        setState(() {
          _selectedStartDate = parsed;
        });
        // Clear end date if it's before the new start date
        if (_endDateController.text.isNotEmpty) {
          final endDate = _parseDisplayDate(_endDateController.text);
          if (endDate != null && endDate.isBefore(parsed)) {
            _endDateController.clear();
          }
        }
      }
    }
  }

  /// Parse display format (dd MMM yyyy) to DateTime
  DateTime? _parseDisplayDate(String text) {
    try {
      return DateFormat('dd MMM yyyy').parse(text);
    } catch (_) {
      return null;
    }
  }

  /// Convert display format to API format (yyyy-MM-dd)
  String _toApiDateFormat(String displayDate) {
    final parsed = _parseDisplayDate(displayDate);
    if (parsed == null) return displayDate;
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  DateTime? _parseApiDate(String text) {
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<DateTimeRange> _buildBlockedRanges(List<TourPlanListItem> plans) {
    final ranges = <DateTimeRange>[];
    for (final plan in plans) {
      final start = _parseApiDate(plan.startDate);
      final end = _parseApiDate(plan.endDate);
      if (start == null || end == null) {
        continue;
      }
      final normalizedStart = _dateOnly(start);
      final normalizedEnd = _dateOnly(end);
      if (normalizedEnd.isBefore(normalizedStart)) {
        continue;
      }
      ranges.add(DateTimeRange(start: normalizedStart, end: normalizedEnd));
    }
    return ranges;
  }

  bool _isDateBlocked(DateTime date, List<DateTimeRange> ranges) {
    final target = _dateOnly(date);
    for (final range in ranges) {
      final start = _dateOnly(range.start);
      final end = _dateOnly(range.end);
      if (!target.isBefore(start) && !target.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  bool _rangesOverlap(
    DateTime start,
    DateTime end,
    List<DateTimeRange> blocked,
  ) {
    final normalizedStart = _dateOnly(start);
    final normalizedEnd = _dateOnly(end);
    for (final range in blocked) {
      final rangeStart = _dateOnly(range.start);
      final rangeEnd = _dateOnly(range.end);
      if (!normalizedEnd.isBefore(rangeStart) &&
          !normalizedStart.isAfter(rangeEnd)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateTourRequest(
        placeOfVisit: _placeController.text.trim(),
        startDate: _toApiDateFormat(_startDateController.text.trim()),
        endDate: _toApiDateFormat(_endDateController.text.trim()),
        purposeOfVisit: _purposeController.text.trim(),
      );

      final success = await ref
          .read(addTourViewModelProvider.notifier)
          .createTourPlan(request);

      if (mounted) {
        if (success) {
          SnackbarUtils.showSuccess(context, 'Tour plan created successfully');
          context.pop(true);
        } else {
          final state = ref.read(addTourViewModelProvider);
          final errorMessage = state.hasError
              ? state.error.toString().replaceAll('Exception: ', '')
              : 'Failed to create tour plan';
          SnackbarUtils.showError(context, errorMessage);
        }
      }
    }
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
    // Additional check: end date must be on or after start date
    if (_startDateController.text.isNotEmpty) {
      final startDate = _parseDisplayDate(_startDateController.text);
      final endDate = _parseDisplayDate(value);
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        return 'End date must be on or after start date';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final addTourState = ref.watch(addTourViewModelProvider);
    final isLoading = addTourState.isLoading;
    final tourPlansAsync = ref.watch(tourPlanViewModelProvider);
    final blockedRanges = tourPlansAsync.maybeWhen(
      data: _buildBlockedRanges,
      orElse: () => const <DateTimeRange>[],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2C435D),
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
                      SizedBox(height: 8.h),
                      PrimaryTextField(
                        label: const Text("Place of Visit"),
                        hintText: "Enter place of visit",
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
                        firstDate: DateTime.now(),
                        validator: _validateStartDate,
                        selectableDayPredicate: (date) =>
                            !_isDateBlocked(date, blockedRanges),
                      ),
                      SizedBox(height: 16.h),
                      CustomDatePicker(
                        hintText: "End Date",
                        controller: _endDateController,
                        prefixIcon: Icons.calendar_today_outlined,
                        firstDate: _selectedStartDate ?? DateTime.now(),
                        validator: (value) {
                          final basic = _validateEndDate(value);
                          if (basic != null) {
                            return basic;
                          }
                          final startDate = _parseDisplayDate(
                            _startDateController.text,
                          );
                          final endDate = _parseDisplayDate(value ?? '');
                          if (startDate != null &&
                              endDate != null &&
                              _rangesOverlap(
                                startDate,
                                endDate,
                                blockedRanges,
                              )) {
                            return 'Selected dates overlap with an existing tour plan';
                          }
                          return null;
                        },
                        selectableDayPredicate: (date) {
                          if (_selectedStartDate != null &&
                              date.isBefore(_dateOnly(_selectedStartDate!))) {
                            return false;
                          }
                          return !_isDateBlocked(date, blockedRanges);
                        },
                      ),
                      SizedBox(height: 16.h),
                      PrimaryTextField(
                        label: const Text("Purpose of Visit"),
                        hintText: "Enter purpose of the visit",
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
                        onPressed: isLoading ? null : _handleSave,
                        width: double.infinity,
                        size: ButtonSize.medium,
                        isLoading: isLoading,
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
