import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/geofencing_service.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';

/// Directory Visit Card
/// Displays individual directory (party/site/prospect) visit information with clean, modern design
class DirectoryVisitCard extends StatelessWidget {
  final BeatDirectory directory;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onMarkPending;
  final bool isLoading;
  final Position? currentLocation;

  const DirectoryVisitCard({
    super.key,
    required this.directory,
    this.onMarkComplete,
    this.onMarkPending,
    this.isLoading = false,
    this.currentLocation,
  });

  // Get type label text
  String _getTypeLabel() {
    switch (directory.type.toLowerCase()) {
      case 'party':
        return 'Party';
      case 'site':
        return 'Site';
      case 'prospect':
        return 'Prospect';
      default:
        return directory.type;
    }
  }

  // Get type badge color and circle color
  Color _getTypeColor() {
    switch (directory.type.toLowerCase()) {
      case 'party':
        return AppColors.primary; // Blue
      case 'site':
        return AppColors.secondary; // Secondary blue
      case 'prospect':
        return AppColors.success; // Green
      default:
        return AppColors.greyMedium;
    }
  }

  // Calculate distance from current location to directory
  GeofenceResult? _getGeofenceResult() {
    if (currentLocation == null) return null;

    return GeofencingService.instance.validateGeofence(
      userLat: currentLocation!.latitude,
      userLng: currentLocation!.longitude,
      targetLat: directory.location.latitude,
      targetLng: directory.location.longitude,
      radius: GeofencingService.defaultGeofenceRadius,
    );
  }

  // Format visitedAt time to local time
  String _formatVisitedTime(String? visitedAt) {
    if (visitedAt == null || visitedAt.isEmpty) return '--:--';

    try {
      // Parse the ISO 8601 UTC timestamp from backend
      final utcDateTime = DateTime.parse(visitedAt);
      // Convert to local time
      final localDateTime = utcDateTime.toLocal();
      // Format as "10:30 AM"
      return DateFormat('h:mm a').format(localDateTime);
    } catch (e) {
      // If parsing fails, return the original string
      return visitedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisited = directory.visitStatus.status.toLowerCase() == 'visited';
    final geofenceResult = _getGeofenceResult();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leading Circle with type badge below
                    Column(
                      children: [
                        // Circle (color based on type: blue for Party, green for Prospect)
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: _getTypeColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Type badge below circle
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _getTypeLabel(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    // Name, Owner, and Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Directory name
                          Text(
                            directory.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          // Owner name
                          Text(
                            directory.ownerName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          // Location
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location icon and address
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  directory.location.address ?? 'No address available',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Status indicator (Clock or Checkmark)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isVisited
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isVisited ? Icons.check : Icons.schedule_outlined,
                        size: 20.sp,
                        color: isVisited ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),

                // Distance indicator (Geofencing) - Beautiful minimal design
                // Only show for pending visits, not for already visited directories
                if (geofenceResult != null && !isVisited) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: geofenceResult.isWithinGeofence
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          geofenceResult.isWithinGeofence
                              ? Icons.check_circle
                              : Icons.navigation_outlined,
                          size: 16.sp,
                          color: geofenceResult.isWithinGeofence
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          geofenceResult.isWithinGeofence
                              ? 'Within range • ${GeofencingService.instance.formatDistance(geofenceResult.distance)}'
                              : '${GeofencingService.instance.formatDistance(geofenceResult.distance)} away',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: geofenceResult.isWithinGeofence
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Map action buttons - Beautiful minimal design
                SizedBox(height: 12.h),
                Row(
                  children: [
                    // View on Map button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openInMaps(
                          directory.location.latitude,
                          directory.location.longitude,
                          directory.name,
                        ),
                        icon: Icon(Icons.map_outlined, size: 16.sp),
                        label: Text(
                          'View Map',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Get Directions button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: currentLocation != null
                            ? () => _openInDirections(
                                  currentLocation!.latitude,
                                  currentLocation!.longitude,
                                  directory.location.latitude,
                                  directory.location.longitude,
                                  directory.name,
                                )
                            : null,
                        icon: Icon(Icons.directions_outlined, size: 16.sp),
                        label: Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          disabledForegroundColor: AppColors.greyMedium,
                          side: BorderSide(
                            color: currentLocation != null
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.greyMedium.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom section: "Mark as Completed" or "Visited at X"
          if (!isVisited)
            // Mark as Completed section
            InkWell(
              onTap: isLoading ? null : onMarkComplete,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: isLoading
                      ? [
                          SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ]
                      : [
                          Icon(
                            Icons.radio_button_off_rounded,
                            size: 20.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Mark as Completed',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                ),
              ),
            )
          else
            // Visited at section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.greyLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Visited at ${_formatVisitedTime(directory.visitStatus.visitedAt)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Open location in Google Maps
  Future<void> _openInMaps(
    double latitude,
    double longitude,
    String locationName,
  ) async {
    try {
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error handling is silent
    }
  }

  /// Open directions from current location to destination
  Future<void> _openInDirections(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
    String destinationName,
  ) async {
    try {
      final directionsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving',
      );

      if (await canLaunchUrl(directionsUrl)) {
        await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error handling is silent
    }
  }
}
