import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import '../model/odometer.model.dart';
import '../vm/odometer.vm.dart';

class OdometerScreen extends ConsumerWidget {
  const OdometerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odometerState = ref.watch(odometerViewModelProvider);
    final activeTrip = odometerState.value;
    final bool isInProgress = activeTrip?.isInProgress == true;
    final bool isCompleted = activeTrip?.isCompleted == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Odometer',
            style: TextStyle(fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            _buildStatusHeader(activeTrip),
            SizedBox(height: 12.h),
            // Hide button when trip is completed (like attendance)
            if (!isCompleted) _buildActionButton(context, isInProgress, activeTrip),
            SizedBox(height: 12.h),
            _buildTodaySummary(activeTrip),
            SizedBox(height: 12.h),
            _buildMonthlySummary(context, ref), // Pass ref here
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OdometerReading? activeTrip) {
    // Determine status based on active trip state
    String statusText;
    Color statusColor;
    Color backgroundColor;

    if (activeTrip == null) {
      statusText = "not started";
      statusColor = AppColors.textSecondary;
      backgroundColor = AppColors.textSecondary.withValues(alpha: 0.15);
    } else if (activeTrip.isInProgress) {
      statusText = "in progress";
      statusColor = AppColors.success;
      backgroundColor = AppColors.success.withValues(alpha: 0.15);
    } else {
      statusText = "completed";
      statusColor = AppColors.info;
      backgroundColor = AppColors.info.withValues(alpha: 0.15);
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Text(
            "Today's Status",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool inProgress,
      OdometerReading? data) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: inProgress ? AppColors.red500 : AppColors.secondary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () =>
            showDialog(
              context: context,
              builder: (context) =>
                  OdometerReadingForm(isStop: inProgress, activeData: data),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(inProgress ? Icons.stop_circle_outlined : Icons
                .play_circle_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
                inProgress ? "Stop Odometer Reading" : "Start Odometer Reading",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(OdometerReading? data) {
    const double factor = 0.621371;
    String getK(double? v, String u) {
      if (v == null) return "--";
      // Normalize unit to uppercase for comparison (API returns lowercase)
      final normalizedUnit = u.toUpperCase();
      return (normalizedUnit == "KM" || normalizedUnit == "KMS")
          ? v.toStringAsFixed(0)
          : (v / factor).toStringAsFixed(0);
    }
    String getM(double? v, String u) {
      if (v == null) return "--";
      final normalizedUnit = u.toUpperCase();
      return (normalizedUnit == "MILES" || normalizedUnit == "MILE")
          ? v.toStringAsFixed(0)
          : (v * factor).toStringAsFixed(0);
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                    Icons.trending_up, color: AppColors.secondary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                "Today's Summary",
                style: TextStyle(fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _summaryRow("Odometer Start Reading",
              getK(data?.startReading, data?.unit ?? "KM"),
              getM(data?.startReading, data?.unit ?? "KM"),
              const Color(0xFFF1F7FF)),
          SizedBox(height: 12.h),
          _summaryRow("Odometer Stop Reading",
              getK(data?.stopReading, data?.unit ?? "KM"),
              getM(data?.stopReading, data?.unit ?? "KM"),
              const Color(0xFFFFEBF0)),
          SizedBox(height: 12.h),
          _summaryRow("Total Distance Travelled",
              getK(data?.distanceTravelled, data?.unit ?? "KM"),
              getM(data?.distanceTravelled, data?.unit ?? "KM"),
              const Color(0xFFE8F9F1), isSuccess: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String k, String m, Color bg,
      {bool isSuccess = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
              fontSize: 11.sp, color: AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$k KM", style: TextStyle(fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppColors.success : AppColors
                      .textPrimary)),
              Text("$m MILES", style: TextStyle(fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppColors.success : AppColors
                      .textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(odometerMonthlySummaryProvider);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                  Icons.bar_chart, color: AppColors.secondary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text("Monthly Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp))
          ]),
          SizedBox(height: 24.h),
          summaryAsync.when(
            data: (summary) =>
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("${summary.daysCompleted}",
                        "Days\nCompleted"),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _stat("${summary.totalDistance.toStringAsFixed(0)} ${summary
                        .unit}", "Total Distance\nTravelled"),
                  ],
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Text("Error loading summary",
                    style: TextStyle(color: AppColors.error, fontSize: 12.sp)),
          ),
          SizedBox(height: 14.h),
          PrimaryButton(
            label: "View Details",
            onPressed: () {
              context.push(
                '/odometer-list',
                extra: {
                  'month': DateTime.now(),
                  'filter': null,
                },
              );
            },
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) =>
      Column(children: [
        Text(v, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(l, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary))
      ]);
}

class OdometerReadingForm extends ConsumerStatefulWidget {
  final bool isStop;
  final OdometerReading? activeData;

  const OdometerReadingForm({super.key, required this.isStop, this.activeData});

  @override
  ConsumerState<OdometerReadingForm> createState() =>
      _OdometerReadingFormState();
}

class _OdometerReadingFormState extends ConsumerState<OdometerReadingForm> {
  final _formKey = GlobalKey<FormState>();
  final _readingController = TextEditingController();
  final _descriptionController = TextEditingController();
  String unit = "KM";
  File? _image;
  bool _showValidationErrors = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isStop) {
      unit = widget.activeData?.unit.toUpperCase() ?? "KM";
    }
  }

  void _toggleUnit(String newUnit) {
    if (_showValidationErrors || unit == newUnit) return;

    double? currentVal = double.tryParse(_readingController.text);
    if (currentVal != null) {
      const double factor = 0.621371;
      double converted = (newUnit == "MILES")
          ? currentVal * factor
          : currentVal / factor;
      _readingController.text = converted.toStringAsFixed(0);
    }
    setState(() => unit = newUnit);
  }

  Widget _unitToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      // Add internal padding for the selection pill effect
      decoration: BoxDecoration(
        color: Colors.white, // Match field background
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitBtn("KM"),
          _unitBtn("MILES"),
        ],
      ),
    );
  }

  Widget _unitBtn(String u) {
    bool isSelected = unit == u;
    return GestureDetector(
      onTap: () => _toggleUnit(u),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          u,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp, // Slightly larger for readability
          ),
        ),
      ),
    );
  }

  Widget _buildInlineError(String message) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            message,
            style: TextStyle(color: AppColors.error,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: () {
            if (_showValidationErrors) {
              setState(() {
                _showValidationErrors =
                    !(_formKey.currentState?.validate() ?? false) ||
                        _image == null;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.isStop ? "Odometer Stop" : "Odometer Start",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    GestureDetector(onTap: () => context.pop(),
                        child: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isStop) ...[
                      // Start Reading Section Header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(Icons.info_outline,
                                  color: AppColors.info, size: 16.sp),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Start Reading Details",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Start Reading (read-only)
                      PrimaryTextField(
                          label: Text("Start Reading",
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          hintText: "Start meter reading",
                          controller: TextEditingController(text: widget
                              .activeData?.startReading.toStringAsFixed(0) ?? ""),
                          prefixIcon: Icons.speed,
                          enabled: false),
                      SizedBox(height: 12.h),

                      // Start Description (read-only)
                      PrimaryTextField(
                          label: Text("Start Description",
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          hintText: "No description",
                          controller: TextEditingController(
                              text: widget.activeData?.description ?? ""),
                          prefixIcon: Icons.description_outlined,
                          enabled: false,
                          maxLines: 2),
                      SizedBox(height: 12.h),

                      // Start Image Display
                      Text(
                        "Start Reading Image",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _networkImageBox("Start Reading Image",
                          widget.activeData?.startReadingImage),
                      SizedBox(height: 16.h),

                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.border,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                      ),

                      // Stop Reading Section Header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(Icons.edit,
                                  color: AppColors.secondary, size: 16.sp),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Stop Reading Details",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Align top to match text field
                      children: [
                        Expanded(
                          child: PrimaryTextField(
                            controller: _readingController,
                            hintText: widget.isStop
                                ? "Stop meter reading"
                                : "Start meter reading",
                            prefixIcon: Icons.speed,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                            (v == null || v.isEmpty)
                                ? "Reading is mandatory"
                                : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Use a fixed height for the toggle that matches the text field height
                        SizedBox(
                          height: 54.h,
                          // Standard height for most PrimaryTextFields
                          child: _unitToggle(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _imagePickerBox(widget.isStop
                        ? "Stop Reading Image"
                        : "Start Reading Image"),

                    if (_showValidationErrors && _image == null)
                      _buildInlineError("Reading image is mandatory"),

                    SizedBox(height: 16.h),
                    PrimaryTextField(
                      label: widget.isStop
                          ? Text("Stop Description",
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary))
                          : null,
                      hintText: widget.isStop ? "Enter stop description" : "Enter description",
                      controller: _descriptionController,
                      prefixIcon: Icons.description_outlined,
                      hasFocusBorder: true,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: 24.h),
                    // Error message display
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 16.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _errorMessage = null),
                              child: Icon(Icons.close, color: AppColors.error, size: 16.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    PrimaryButton(
                      label: _isSubmitting ? "Submitting..." : "Submit Reading",
                      onPressed: _isSubmitting ? null : () async {
                        setState(() {
                          _showValidationErrors = true;
                          _errorMessage = null;
                        });

                        if ((_formKey.currentState?.validate() ?? false) &&
                            _image != null) {
                          setState(() => _isSubmitting = true);

                          try {
                            final val = double.parse(_readingController.text);
                            if (widget.isStop) {
                              await ref
                                  .read(odometerViewModelProvider.notifier)
                                  .stopTrip(
                                  reading: val,
                                  imagePath: _image!.path,
                                  description: _descriptionController.text);
                            } else {
                              await ref
                                  .read(odometerViewModelProvider.notifier)
                                  .startTrip(
                                  reading: val,
                                  unit: unit,
                                  imagePath: _image!.path,
                                  description: _descriptionController.text);
                            }
                              // Success - close the dialog
                              if (mounted) context.pop();
                          } catch (e) {
                            setState(() {
                              _isSubmitting = false;
                              _errorMessage = e.toString().replaceAll('Exception: ', '');
                            });
                          }
                        }
                      },
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Display network image from URL (for start image from API)
  Widget _networkImageBox(String label, String? imageUrl) {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported,
                      color: AppColors.textSecondary, size: 30.sp),
                  SizedBox(height: 8.h),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.secondary,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image,
                            color: AppColors.textSecondary, size: 30.sp),
                        SizedBox(height: 8.h),
                        Text("Failed to load image",
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColors.error)),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  // UPDATED: Standardized white background for image picker
  Widget _imagePickerBox(String label) {
    return GestureDetector(
      onTap: () async {
        final x = await ref
            .read(odometerViewModelProvider.notifier)
            .pickImage();
        if (x != null) {
          setState(() {
            _image = File(x.path);
            _showValidationErrors = false;
          });
        }
      },
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _showValidationErrors && _image == null
                ? AppColors.error
                : AppColors.border),
            borderRadius: BorderRadius.circular(8.r)),
        child: _image == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.camera_alt, color: AppColors.secondary, size: 30.sp),
          SizedBox(height: 8.h),
          Text(label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary))
        ])
            : ClipRRect(borderRadius: BorderRadius.circular(8.r),
            child: Image.file(_image!, fit: BoxFit.cover)),
      ),
    );
  }
}