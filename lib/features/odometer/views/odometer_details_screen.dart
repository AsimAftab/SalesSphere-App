import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import '../vm/odometer_details.vm.dart';

class OdometerDetailsScreen extends ConsumerWidget {
  final String id;

  const OdometerDetailsScreen({super.key, required this.id});

  // Method to open location in Google Maps
  Future<void> _openMap(String address) async {
    final googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(
            address)}");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    }
  }

  // IMAGE PREVIEW LOGIC (Implemented from Expense Claim logic)
  void _showImagePreview(BuildContext context, String? path, String label) {
    if (path == null || path.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10.w),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: path.startsWith('http')
                        ? Image.network(path, fit: BoxFit.contain)
                        : Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: IconButton(
                    icon: const Icon(
                        Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(odometerDetailsViewModelProvider(id));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Odometer Details',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          detailsAsync.when(
            data: (data) => _buildContent(context, data),
            loading: () =>
                Skeletonizer(
                    enabled: true, child: _buildContent(context, _mockData())),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic data) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 110.h, 16.w, 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Card
          _buildInfoCard([
            _buildDetailRow(Icons.calendar_today_outlined, "Start Date & Time",
                dateFormat.format(data.startTime)),
            _buildDetailRow(Icons.calendar_today_outlined, "End Date & Time",
                dateFormat.format(data.stopTime)),
          ]),
          SizedBox(height: 16.h),

          // Readings Card
          _buildInfoCard([
            _buildDetailRow(Icons.speed, "Starting Reading",
                "${data.startReading.toInt()} Km"),
            _buildDetailRow(Icons.speed, "Ending Reading",
                "${data.stopReading.toInt()} Km"),
            _buildDetailRow(Icons.route, "Total Distance Travelled",
                "${data.distanceTravelled.toInt()} Km", isHighlighted: true),
          ]),
          SizedBox(height: 16.h),

          // Location Card
          _buildInfoCard([
            _buildDetailRow(
              Icons.location_on_outlined,
              "Start Reading Location",
              data.startLocation,
              hasLink: true,
              onLinkTap: () => _openMap(data.startLocation),
            ),
            _buildDetailRow(
              Icons.location_on_outlined,
              "Stop Reading Location",
              data.stopLocation,
              hasLink: true,
              onLinkTap: () => _openMap(data.stopLocation),
            ),
          ]),
          SizedBox(height: 16.h),

          _buildInfoCard([
            _buildDetailRow(Icons.description_outlined, "Description",
                data.description ?? "No description provided"),
          ]),
          SizedBox(height: 24.h),

          Text("Odometer Images", style: TextStyle(fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark)),
          SizedBox(height: 12.h),

          _buildImageSection(
              context, "Starting Reading", data.startReadingImage),
          SizedBox(height: 12.h),
          _buildImageSection(context, "Ending Reading", data.stopReadingImage),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isHighlighted = false, bool hasLink = false, VoidCallback? onLinkTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 18.sp, color: Colors.grey.shade400),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade500)),
                    if (hasLink) ...[
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: onLinkTap,
                        child: Icon(
                            Icons.open_in_new, size: 12.sp, color: Colors.blue),
                      )
                    ],
                  ],
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight
                        .w500,
                    color: isHighlighted ? AppColors.primary : Colors.grey
                        .shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, String label,
      String? imagePath) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, imagePath, label),
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Stack(
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imagePath.startsWith('http')
                    ? Image.network(imagePath, width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover)
                    : Image.file(File(imagePath), width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined, size: 40.sp,
                        color: Colors.grey.shade400),
                    SizedBox(height: 8.h),
                    Text("No image available", style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            if (imagePath != null && imagePath.isNotEmpty)
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('Tap to preview', style: TextStyle(
                          color: Colors.white, fontSize: 10.sp)),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(label, style: TextStyle(color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic _mockData() {
    return (
    startTime: DateTime.now(),
    stopTime: DateTime.now(),
    startReading: 0,
    stopReading: 0,
    distanceTravelled: 0,
    startLocation: "Loading...",
    stopLocation: "Loading...",
    description: "Loading summary...",
    startReadingImage: "",
    stopReadingImage: "",
    );
  }
}