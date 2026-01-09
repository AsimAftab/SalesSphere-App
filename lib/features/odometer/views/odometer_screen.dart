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
    final bool isInProgress = activeTrip != null && activeTrip.stopReading == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Odometer',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
            _buildStatusHeader(isInProgress),
            SizedBox(height: 12.h),
            _buildActionButton(context, isInProgress, activeTrip),
            SizedBox(height: 12.h),
            _buildTodaySummary(activeTrip),
            SizedBox(height: 12.h),
            _buildMonthlySummary(context, ref), // Pass ref here
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool inProgress) {
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
              color: inProgress
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              inProgress ? "in progress" : "not started",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: inProgress ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool inProgress, OdometerReading? data) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: inProgress ? AppColors.red500 : AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => OdometerReadingForm(isStop: inProgress, activeData: data),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(inProgress ? Icons.stop_circle_outlined : Icons.play_circle_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Text(inProgress ? "Stop Odometer Reading" : "Start Odometer Reading",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(OdometerReading? data) {
    const double factor = 0.621371;
    String getK(double? v, String u) => v == null ? "--" : (u == "KM" ? v : v / factor).toStringAsFixed(0);
    String getM(double? v, String u) => v == null ? "--" : (u == "MILES" ? v : v * factor).toStringAsFixed(0);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
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
                child: Icon(Icons.trending_up, color: AppColors.secondary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                "Today's Summary",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _summaryRow("Odometer Start Reading", getK(data?.startReading, data?.unit ?? "KM"), getM(data?.startReading, data?.unit ?? "KM"), const Color(0xFFF1F7FF)),
          SizedBox(height: 12.h),
          _summaryRow("Odometer Stop Reading", getK(data?.stopReading, data?.unit ?? "KM"), getM(data?.stopReading, data?.unit ?? "KM"), const Color(0xFFFFEBF0)),
          SizedBox(height: 12.h),
          _summaryRow("Total Distance Travelled", getK(data?.distanceTravelled, data?.unit ?? "KM"), getM(data?.distanceTravelled, data?.unit ?? "KM"), const Color(0xFFE8F9F1), isSuccess: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String k, String m, Color bg, {bool isSuccess = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$k KM", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isSuccess ? AppColors.success : AppColors.textPrimary)),
              Text("$m MILES", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isSuccess ? AppColors.success : AppColors.textPrimary)),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
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
              child: Icon(Icons.bar_chart, color: AppColors.secondary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text("Monthly Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp))
          ]),
          SizedBox(height: 24.h),
          summaryAsync.when(
            data: (summary) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat("${summary.totalReadings}", "Total Number of\nOdometer Readings"),
                Container(width: 1, height: 40, color: AppColors.border),
                _stat("${summary.totalDistance.toStringAsFixed(0)} ${summary.unit}", "Total Distance\nTravelled"),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text("Error loading summary",
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

  Widget _stat(String v, String l) => Column(children: [
    Text(v, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
    SizedBox(height: 4.h),
    Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary))
  ]);
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

  @override
  void initState() {
    super.initState();
    if (widget.isStop) {
      unit = widget.activeData?.unit ?? "KM";
      // Prefill description from active state
      _descriptionController.text = widget.activeData?.description ?? "";
    }
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

  Widget _unitToggle() {
    return Container(
      padding: EdgeInsets.all(4.w), // Add internal padding for the selection pill effect
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
            style: TextStyle(color: AppColors.error, fontSize: 12.sp, fontWeight: FontWeight.w400),
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
                _showValidationErrors = !(_formKey.currentState?.validate() ?? false) || _image == null;
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.isStop ? "Odometer Stop" : "Odometer Start",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isStop) ...[
                      PrimaryTextField(
                          hintText: "Start meter reading",
                          controller: TextEditingController(text: widget.activeData?.startReading.toStringAsFixed(0)),
                          prefixIcon: Icons.speed,
                          enabled: false),
                      SizedBox(height: 12.h),
                      // Display the image captured during 'Start' phase
                      _staticImageBox("Start Reading Image", widget.activeData?.startReadingImage),
                      SizedBox(height: 12.h),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align top to match text field
                      children: [
                        Expanded(
                          child: PrimaryTextField(
                            controller: _readingController,
                            hintText: widget.isStop ? "Stop meter reading" : "Start meter reading",
                            prefixIcon: Icons.speed,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) => (v == null || v.isEmpty) ? "Reading is mandatory" : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Use a fixed height for the toggle that matches the text field height
                        SizedBox(
                          height: 54.h, // Standard height for most PrimaryTextFields
                          child: _unitToggle(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _imagePickerBox(widget.isStop ? "Stop Reading Image" : "Start Reading Image"),

                    if (_showValidationErrors && _image == null)
                      _buildInlineError("Reading image is mandatory"),

                    SizedBox(height: 16.h),
                    PrimaryTextField(
                      hintText: "Description",
                      controller: _descriptionController,
                      prefixIcon: Icons.description_outlined,
                      hasFocusBorder: true,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: 24.h),
                    PrimaryButton(
                      label: "Submit Reading",
                      onPressed: () {
                        setState(() { _showValidationErrors = true; });

                        if ((_formKey.currentState?.validate() ?? false) && _image != null) {
                          final val = double.parse(_readingController.text);
                          if (widget.isStop) {
                            ref.read(odometerViewModelProvider.notifier).stopTrip(
                                reading: val,
                                imagePath: _image!.path,
                                description: _descriptionController.text);
                          } else {
                            ref.read(odometerViewModelProvider.notifier).startTrip(
                                reading: val,
                                unit: unit,
                                imagePath: _image!.path,
                                description: _descriptionController.text);
                          }
                          context.pop();
                        }
                      },
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

  // UPDATED: Background color white to match other input fields
  Widget _staticImageBox(String label, String? imagePath) => Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r)),
      child: imagePath == null || imagePath.isEmpty
          ? Center(child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)))
          : ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.file(File(imagePath), fit: BoxFit.cover),
      ));

  // UPDATED: Standardized white background for image picker
  Widget _imagePickerBox(String label) {
    return GestureDetector(
      onTap: () async {
        final x = await ref.read(odometerViewModelProvider.notifier).pickImage();
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
            border: Border.all(color: _showValidationErrors && _image == null ? AppColors.error : AppColors.border),
            borderRadius: BorderRadius.circular(8.r)),
        child: _image == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.camera_alt, color: AppColors.secondary, size: 30.sp),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary))])
            : ClipRRect(borderRadius: BorderRadius.circular(8.r), child: Image.file(_image!, fit: BoxFit.cover)),
      ),
    );
  }
}