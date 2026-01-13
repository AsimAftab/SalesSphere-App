import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import '../model/odometer.model.dart';
import '../vm/odometer.vm.dart';

class OdometerScreen extends ConsumerStatefulWidget {
  const OdometerScreen({super.key});

  @override
  ConsumerState<OdometerScreen> createState() => _OdometerScreenState();
}

class _OdometerScreenState extends ConsumerState<OdometerScreen> {
  int _currentTripIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.93);

  @override
  Widget build(BuildContext context) {
    final odometerState = ref.watch(odometerViewModelProvider);
    final statusResponse = odometerState.value;
    final hasActiveTrip = ref.read(odometerViewModelProvider.notifier).hasActiveTrip;
    final allTrips = statusResponse?.trips ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Odometer',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: statusResponse == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  _buildStatusHeader(hasActiveTrip, allTrips),
                  SizedBox(height: 20.h),

                  if (!hasActiveTrip)
                    _buildAddTripButton(context)
                  else
                    _buildActiveTripIndicator(allTrips.firstWhere((t) => t.isInProgress)),

                  SizedBox(height: 24.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timeline_rounded, color: AppColors.secondary, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Today's Trips",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${allTrips.where((t) => t.isCompleted).length} / ${allTrips.length}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (allTrips.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildEmptyState(),
              )
            else ...[
              SizedBox(
                height: 250.h,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: allTrips.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentTripIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final trip = allTrips[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: _buildTripCard(context, ref, trip),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _buildPageIndicator(allTrips.length),
            ],

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  _buildMonthlySummary(context, ref),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = _currentTripIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(bool isActive, List<OdometerReading> allTrips) {
    final hasAnyCompletedTrips = allTrips.any((t) => t.isCompleted);
    String statusText;
    Color badgeColor;
    String? timeInfo;

    if (isActive) {
      statusText = "On Trip";
      badgeColor = AppColors.secondary;
      final activeTrip = allTrips.firstWhere((t) => t.isInProgress, orElse: () => allTrips.first);
      if (activeTrip.startTime != null) {
        try {
          final startTime = DateTime.parse(activeTrip.startTime.toString()).toLocal();
          timeInfo = DateFormat('hh:mm a').format(startTime);
        } catch (e) {
          timeInfo = null;
        }
      }
    } else if (hasAnyCompletedTrips) {
      statusText = "Completed";
      badgeColor = AppColors.success;
      final completedCount = allTrips.where((t) => t.isCompleted).length;
      timeInfo = "$completedCount trip${completedCount > 1 ? 's' : ''} completed";
    } else {
      statusText = "Not Started";
      badgeColor = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'Today\'s Status',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (timeInfo != null) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeInfo,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTripButton(BuildContext context) {
    return PrimaryButton(
      label: "Start New Trip",
      onPressed: () => _showStartTripDialog(context, ref),
      leadingIcon: Icons.add_rounded,
      height: 52.h,
    );
  }

  // ENHANCED STOP BUTTON DESIGN
  Widget _buildActiveTripIndicator(OdometerReading trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.red500.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.red500.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.red500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.red500,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip #${trip.tripNumber}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Currently Active",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Pulse animation dot
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.red500.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.red500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Stop Button
          CustomButton(
            label: "Stop Trip",
            onPressed: () => _showStopTripDialog(context, ref, trip),
            backgroundColor: AppColors.red500,
            leadingIcon: Icons.stop_circle_outlined,
            trailingIcon: Icons.arrow_forward_rounded,
            height: 50.h,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, WidgetRef ref, OdometerReading trip) {
    final unit = trip.unit.toUpperCase();
    final isCompleted = trip.isCompleted;
    final distance = (trip.stopReading != null) ? (trip.stopReading! - trip.startReading) : 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trip ${trip.tripNumber}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_rounded : Icons.sync_rounded,
                      size: 14.sp,
                      color: isCompleted ? AppColors.success : AppColors.secondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isCompleted ? "Completed" : "Active",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? AppColors.success : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildReadingBox(
                  "Start Reading",
                  trip.startReading.toInt().toString(),
                  unit,
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildReadingBox(
                  "Stop Reading",
                  trip.stopReading != null ? trip.stopReading!.toInt().toString() : "---",
                  unit,
                  AppColors.red500.withValues(alpha: 0.1),
                  AppColors.red500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Distance Travelled",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCompleted ? distance.toInt().toString() : "...",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingBox(String label, String value, String unit, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(unit, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_outlined, size: 40.sp, color: AppColors.textSecondary),
          SizedBox(height: 10.h),
          Text("No trips recorded today", style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(odometerMonthlySummaryProvider);
    return summaryAsync.when(
      data: (summary) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.bar_chart_rounded, color: AppColors.secondary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Monthly Summary",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryStatItem("${summary.daysCompleted}", "Total Trips"),
                  Container(width: 1, height: 40.h, color: AppColors.border),
                  _summaryStatItem("${summary.totalDistance.toStringAsFixed(0)} ${summary.unit}", "Total Distance"),
                ],
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                label: "View Details",
                onPressed: () {
                  context.push('/odometer-list', extra: {'month': DateTime.now(), 'filter': null});
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _summaryStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showStartTripDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const OdometerReadingForm(isStop: false));
  }

  void _showStopTripDialog(BuildContext context, WidgetRef ref, OdometerReading trip) {
    showDialog(context: context, builder: (context) => OdometerReadingForm(isStop: true, activeData: trip));
  }
}

class OdometerReadingForm extends ConsumerStatefulWidget {
  final bool isStop;
  final OdometerReading? activeData;

  const OdometerReadingForm({super.key, required this.isStop, this.activeData});

  @override
  ConsumerState<OdometerReadingForm> createState() => _OdometerReadingFormState();
}

class _OdometerReadingFormState extends ConsumerState<OdometerReadingForm> {
  final _formKey = GlobalKey<FormState>();
  final _readingController = TextEditingController();
  final _descriptionController = TextEditingController();
  String unit = "KM";
  File? _image;
  bool _showValidationErrors = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isStop && widget.activeData != null) {
      unit = widget.activeData!.unit.toUpperCase();
      _readingController.text = widget.activeData!.stopReading?.toStringAsFixed(0) ?? "";
      _descriptionController.text = widget.activeData!.description ?? "";
    }
  }

  @override
  void dispose() {
    _readingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleUnit(String newUnit) {
    if (_showValidationErrors || unit == newUnit) return;
    double? currentVal = double.tryParse(_readingController.text);
    if (currentVal != null) {
      const double factor = 0.621371;
      double converted = (newUnit == "MILES") ? currentVal * factor : currentVal / factor;
      _readingController.text = converted.toStringAsFixed(0);
    }
    setState(() => unit = newUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isStop ? "Stop Trip" : "New Trip",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => context.pop(),
                  )
                ],
              ),
              SizedBox(height: 20.h),

              if (widget.isStop && widget.activeData != null)
                _buildTripStartInfo(widget.activeData!),

              const Text("Odometer Reading", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _readingController,
                      hintText: "000000",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Show unit toggle for new trip, or display locked unit for stop trip
                  widget.isStop
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            unit,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        )
                      : _buildUnitToggle(),
                ],
              ),
              SizedBox(height: 20.h),

              const Text("Photo Proof", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8.h),
              _buildImagePicker(),
              if (_showValidationErrors && _image == null)
                Text("Photo required", style: TextStyle(color: AppColors.error, fontSize: 12.sp)),

              SizedBox(height: 20.h),

              // DESCRIPTION FIELD IS NOW REQUIRED
              const Text("Description", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 8.h),
              PrimaryTextField(
                controller: _descriptionController,
                hintText: "Enter details...",
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24.h),
              PrimaryButton(
                label: widget.isStop ? "Complete Trip" : "Start Trip",
                onPressed: _isSubmitting ? null : _handleSubmit,
                isLoading: _isSubmitting,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8.r)),
      child: Row(children: [_unitBtn("KM"), _unitBtn("MILES")]),
    );
  }

  Widget _unitBtn(String u) {
    bool selected = unit == u;
    return GestureDetector(
      onTap: () => _toggleUnit(u),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(color: selected ? AppColors.secondary : Colors.transparent, borderRadius: BorderRadius.circular(8.r)),
        child: Text(u, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        final x = await ref.read(odometerViewModelProvider.notifier).pickImage();
        if (x != null) setState(() { _image = File(x.path); _showValidationErrors = false; });
      },
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _image == null ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.border,
            width: _image == null ? 1.5 : 1,
          ),
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: AppColors.secondary, size: 28.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to capture photo",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _image = null);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTripStartInfo(OdometerReading tripData) {
    AppLogger.d('📸 Trip data - startReadingImage: ${tripData.startReadingImage}, description: ${tripData.description}');

    final dio = ref.read(dioClientProvider);
    final baseUrl = dio.options.baseUrl;

    // Helper to get the correct image URL (full URL or prepend baseUrl)
    String getImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return '';
      // If already a full URL, return as is
      if (imagePath.startsWith('http')) return imagePath;
      // Otherwise prepend baseUrl
      return '$baseUrl$imagePath';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.info_outline, color: AppColors.secondary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                "Trip Started At",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.speed_rounded,
                  "${tripData.startReading.toInt()} ${tripData.unit.toUpperCase()}",
                ),
              ),
              if (tripData.startTime != null) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildInfoChip(
                    Icons.access_time,
                    DateFormat('hh:mm a').format(tripData.startTime!.toLocal()),
                  ),
                ),
              ],
            ],
          ),
          if (tripData.startReadingImage != null) ...[
            SizedBox(height: 12.h),
            Text(
              "Start Image Proof",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: getImageUrl(tripData.startReadingImage),
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 100.h,
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 100.h,
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
          if (tripData.description != null && tripData.description!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Description",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              tripData.description!,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.secondary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _showValidationErrors = true;
    });

    if ((_formKey.currentState?.validate() ?? false) && _image != null) {
      setState(() => _isSubmitting = true);
      try {
        final val = double.parse(_readingController.text);
        if (widget.isStop) {
          await ref.read(odometerViewModelProvider.notifier).stopTrip(
            reading: val,
            imagePath: _image!.path,
            description: _descriptionController.text,
          );
        } else {
          await ref.read(odometerViewModelProvider.notifier).startTrip(
            reading: val,
            unit: unit,
            imagePath: _image!.path,
            description: _descriptionController.text,
          );
        }
        if (mounted) context.pop();
      } catch (e) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}