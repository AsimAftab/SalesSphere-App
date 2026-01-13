import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/odometer/model/odometer.model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../vm/odometer_details.vm.dart';

class OdometerDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  final String? tripIds; // Comma-separated trip IDs for tabs

  const OdometerDetailsScreen({super.key, required this.id, this.tripIds});

  @override
  ConsumerState<OdometerDetailsScreen> createState() =>
      _OdometerDetailsScreenState();
}

class _OdometerDetailsScreenState extends ConsumerState<OdometerDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tripIdsList = [];
  Map<String, int> _tripNumbersMap = {}; // Map of tripId -> tripNumber
  final ScrollController _scrollController = ScrollController();
  bool _showTabs = true;

  @override
  void initState() {
    super.initState();
    // Parse trip IDs from comma-separated string
    if (widget.tripIds != null && widget.tripIds!.isNotEmpty) {
      _tripIdsList = widget.tripIds!.split(',');
      _tabController = TabController(length: _tripIdsList.length, vsync: this);
    }
    
    // Add scroll listener to hide/show tabs
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Show tabs when scrolling up, hide when scrolling down
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showTabs) {
        setState(() => _showTabs = true);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showTabs && _scrollController.offset > 20) {
        setState(() => _showTabs = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  // Method to open location in Google Maps
  Future<void> _openInMaps(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  // IMAGE PREVIEW LOGIC (Implemented from Expense Claim logic)
  void _showImagePreview(BuildContext context, String? path, String label) {
    if (path == null || path.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTripId = _tabController != null
        ? _tripIdsList[_tabController!.index]
        : widget.id;

    final detailsAsync = ref.watch(
      odometerDetailsViewModelProvider(currentTripId),
    );

    // Update trip numbers map when data loads
    detailsAsync.whenData((data) {
      if (!_tripNumbersMap.containsKey(currentTripId)) {
        _tripNumbersMap[currentTripId] = data.tripNumber;
      }
    });

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
        bottom: _tabController != null
            ? PreferredSize(
                preferredSize: Size.fromHeight(_showTabs ? 50.h : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: _showTabs ? 50.h : 0,
                  color: Colors.white.withValues(alpha: 0.9),
                  child: _showTabs
                      ? TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                          onTap: (index) => setState(() {}),
                          tabs: List.generate(
                            _tripIdsList.length,
                            (index) {
                              final tripId = _tripIdsList[index];
                              final tripNumber = _tripNumbersMap[tripId] ?? (index + 1);
                              return Tab(text: 'Trip $tripNumber');
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              )
            : null,
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
            loading: () => Skeletonizer(
              enabled: true,
              child: _buildContent(context, _mockData()),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, OdometerDetails data) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final topPadding = _tabController != null 
        ? (_showTabs ? 170.h : 120.h) 
        : 110.h;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.fromLTRB(16.w, topPadding, 16.w, 30.h),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip badge if multiple trips
            if (_tabController != null)
              Center(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'Trip #${data.tripNumber}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
          // Time Card
          _buildInfoCard([
            _buildDetailRow(
              Icons.calendar_today_outlined,
              "Start Date & Time",
              dateFormat.format(data.startTime),
            ),
            if (data.stopTime != null)
              _buildDetailRow(
                Icons.calendar_today_outlined,
                "End Date & Time",
                dateFormat.format(data.stopTime!),
              ),
          ]),
          SizedBox(height: 16.h),

          // Readings Card
          _buildInfoCard([
            _buildDetailRow(
              Icons.speed,
              "Starting Reading",
              "${data.startReading.toInt()} ${data.unit.toLowerCase()}",
            ),
            if (data.stopReading != null)
              _buildDetailRow(
                Icons.speed,
                "Ending Reading",
                "${data.stopReading!.toInt()} ${data.unit.toLowerCase()}",
              ),
            _buildDetailRow(
              Icons.route,
              "Total Distance Travelled",
              "${data.distanceTravelled.toInt()} ${data.unit.toLowerCase()}",
              isHighlighted: true,
            ),
          ]),
          SizedBox(height: 16.h),

          // Start Location Card
          if (data.startLocation != null)
            _buildLocationCard(context, data.startLocation!, 'Start Location'),

          // Stop Location Card
          if (data.stopLocation != null)
            _buildStopLocationCard(context, data.stopLocation!),

          SizedBox(height: 16.h),

          // Start Description Card
          _buildInfoCard([
            _buildDetailRow(
              Icons.description_outlined,
              "Start Description",
              data.displayStartDescription,
            ),
          ]),
          
          // Stop Description Card (if available)
          if (data.stopDescription != null) ...[
            SizedBox(height: 16.h),
            _buildInfoCard([
              _buildDetailRow(
                Icons.description_outlined,
                "Stop Description",
                data.displayStopDescription,
              ),
            ]),
          ],
          
          SizedBox(height: 24.h),

          // Images Section
          Text(
            "Odometer Images",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark,
            ),
          ),
          SizedBox(height: 12.h),

          _buildImageSection(
            context,
            "Starting Reading",
            data.startReadingImage,
          ),
          SizedBox(height: 12.h),
          if (data.stopReadingImage != null)
            _buildImageSection(
              context,
              "Ending Reading",
              data.stopReadingImage,
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    StartLocation location,
    String title,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: title.contains('Start')
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  title.contains('Start') ? Icons.play_arrow : Icons.stop,
                  size: 20.sp,
                  color: title.contains('Start')
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildLocationDetails(context, location),
        ],
      ),
    );
  }

  Widget _buildLocationDetails(
    BuildContext context,
    dynamic location, // StartLocation or StopLocation
  ) {
    final latitude = location.latitude;
    final longitude = location.longitude;
    final address = location.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Location Details',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (address != null)
          Text(
            address,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        SizedBox(height: 12.h),
        Text(
          'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openInMaps(latitude, longitude),
            icon: Icon(Icons.map, size: 18.sp),
            label: Text(
              'Open in Maps',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopLocationCard(BuildContext context, StopLocation location) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.stop, size: 20.sp, color: AppColors.error),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stop Location',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildLocationDetails(context, location),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
    bool hasLink = false,
    VoidCallback? onLinkTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: Colors.grey.shade400),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (hasLink) ...[
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: onLinkTap,
                        child: Icon(
                          Icons.open_in_new,
                          size: 12.sp,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isHighlighted
                        ? AppColors.primary
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    String label,
    String? imagePath,
  ) {
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
                    ? Image.network(
                        imagePath,
                        width: double.infinity,
                        height: 200.h,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 200.h,
                        fit: BoxFit.cover,
                      ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "No image available",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (imagePath != null && imagePath.isNotEmpty)
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Tap to preview',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
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
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OdometerDetails _mockData() {
    return OdometerDetails(
      id: 'loading',
      startTime: DateTime.now(),
      stopTime: DateTime.now(),
      startReading: 0,
      stopReading: 0,
      distanceTravelled: 0,
      startLocation: const StartLocation(
        latitude: 0.0,
        longitude: 0.0,
        address: 'Loading...',
      ),
      stopLocation: const StopLocation(
        latitude: 0.0,
        longitude: 0.0,
        address: 'Loading...',
      ),
      startReadingImage: '',
      stopReadingImage: '',
    );
  }
}
