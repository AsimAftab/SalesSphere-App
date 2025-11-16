import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/geofencing_service.dart';
import 'package:sales_sphere/core/services/location_permission_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';
import 'package:sales_sphere/features/beat_plan/vm/beat_plan.vm.dart';
import 'package:sales_sphere/features/beat_plan/widgets/route_progress_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/directory_visit_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/tracking_status_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/tracking_indicator_widget.dart';

/// Beat Plan Details Screen
/// Shows detailed beat plan with route progress, filter tabs, and party visit cards
class BeatPlanDetailsScreen extends ConsumerStatefulWidget {
  final String beatPlanId;

  const BeatPlanDetailsScreen({
    super.key,
    required this.beatPlanId,
  });

  @override
  ConsumerState<BeatPlanDetailsScreen> createState() => _BeatPlanDetailsScreenState();
}

class _BeatPlanDetailsScreenState extends ConsumerState<BeatPlanDetailsScreen> {
  // Filter state: 'all', 'pending', 'visited'
  String _selectedFilter = 'all';
  String? _loadingVisitId;

  // Current location state for geofencing
  Position? _currentLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Get current location for geofencing
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      // Check location permission
      final permissionService = LocationPermissionService.instance;
      var permission = await permissionService.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await permissionService.requestPermission();
      }

      // Check if permission was granted
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        AppLogger.w('⚠️ Location permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission required for geofencing'),
              backgroundColor: AppColors.warning,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentLocation = position;
      });

      AppLogger.i('📍 Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      AppLogger.e('❌ Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final beatPlanAsync = ref.watch(beatPlanDetailViewModelProvider(widget.beatPlanId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Beat Plan Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: TrackingIndicatorWidget(),
          ),
        ],
      ),
      body: beatPlanAsync.when(
        data: (beatPlan) {
          if (beatPlan == null) {
            return _buildEmptyState();
          }

          return _buildContent(beatPlan);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildContent(BeatPlanDetail beatPlan) {
    // Filter directories based on selected tab
    final filteredDirectories = _getFilteredDirectories(beatPlan.directories);

    // Calculate counts for tabs
    final allCount = beatPlan.directories.length;
    final pendingCount = beatPlan.directories
        .where((p) => p.visitStatus.status.toLowerCase() == 'pending')
        .length;
    final visitedCount = beatPlan.directories
        .where((p) => p.visitStatus.status.toLowerCase() == 'visited')
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(beatPlanDetailViewModelProvider(widget.beatPlanId).notifier).refresh(widget.beatPlanId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beat Plan Name
            Text(
              beatPlan.name,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(beatPlan.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _getStatusText(beatPlan.status),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(beatPlan.status),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Route Progress Card
            RouteProgressCard(
              totalParties: beatPlan.progress.totalDirectories,
              visitedParties: beatPlan.progress.visitedDirectories,
              pendingParties: beatPlan.progress.totalDirectories - beatPlan.progress.visitedDirectories,
              progressPercentage: beatPlan.progress.percentage,
            ),

            SizedBox(height: 10.h),

            // Tracking Status Card
            const TrackingStatusCard(),

            SizedBox(height: 24.h),

            // Filter Tabs
            Row(
              children: [
                _buildFilterTab(
                  label: 'All',
                  count: allCount,
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                SizedBox(width: 10.w),
                _buildFilterTab(
                  label: 'Pending',
                  count: pendingCount,
                  isSelected: _selectedFilter == 'pending',
                  onTap: () => setState(() => _selectedFilter = 'pending'),
                ),
                SizedBox(width: 10.w),
                _buildFilterTab(
                  label: 'Visited',
                  count: visitedCount,
                  isSelected: _selectedFilter == 'visited',
                  onTap: () => setState(() => _selectedFilter = 'visited'),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Directory Visit Cards
            if (filteredDirectories.isEmpty)
              _buildEmptyFilterState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDirectories.length,
                itemBuilder: (context, index) {
                  final directory = filteredDirectories[index];
                  final isLoading = _loadingVisitId == directory.id;

                  return DirectoryVisitCard(
                    directory: directory,
                    isLoading: isLoading,
                    currentLocation: _currentLocation,
                    onMarkComplete: () => _handleMarkVisitComplete(
                      beatPlan.id,
                      directory,
                    ),
                    onMarkPending: () => _handleMarkVisitPending(
                      beatPlan.id,
                      directory.id,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Helper function to get the color for the gradient
    // (Based on your original code)
    Color getColor() {
      if (label == 'All') return AppColors.primary;
      if (label == 'Pending') return AppColors.yellow500;
      return AppColors.success;
    }

    final color = getColor();

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w), //
          decoration: BoxDecoration(
            // --- START: Gradient Logic (from your original code) ---
            gradient: isSelected
                ? LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : AppColors.cardBackground,
            // --- END: Gradient Logic ---

            borderRadius: BorderRadius.circular(14.r), // Using your original 14.r

            // Using your original border logic
            border: Border.all(
              color: isSelected ? color : AppColors.greyLight,
              width: isSelected ? 1.5 : 1,
            ),

            // Using your original shadow logic
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              '$label ($count)', // Combined label and count (from my new code)
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                // Selected text is white, unselected is primary text color
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  List<BeatDirectory> _getFilteredDirectories(List<BeatDirectory> directories) {
    if (_selectedFilter == 'all') {
      return directories;
    } else if (_selectedFilter == 'pending') {
      return directories.where((p) => p.visitStatus.status.toLowerCase() == 'pending').toList();
    } else {
      return directories.where((p) => p.visitStatus.status.toLowerCase() == 'visited').toList();
    }
  }

  Future<void> _handleMarkVisitComplete(
    String beatPlanId,
    BeatDirectory directory,
  ) async {
    // Validate geofence before allowing mark as complete
    if (_currentLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Getting your location... Please try again.'),
            backgroundColor: AppColors.warning,
            action: SnackBarAction(
              label: 'Refresh',
              textColor: Colors.white,
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
      return;
    }

    // Validate geofence
    final geofenceResult = GeofencingService.instance.validateGeofence(
      userLat: _currentLocation!.latitude,
      userLng: _currentLocation!.longitude,
      targetLat: directory.location.latitude,
      targetLng: directory.location.longitude,
      radius: GeofencingService.defaultGeofenceRadius,
    );

    if (!geofenceResult.isWithinGeofence) {
      // User is outside geofence - show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You are ${GeofencingService.instance.formatDistance(geofenceResult.distanceOutside)} '
              'outside the allowed radius.\n\n'
              'Please move within ${GeofencingService.instance.formatDistance(geofenceResult.radius)} '
              'of ${directory.name} to mark as visited.',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Refresh Location',
              textColor: Colors.white,
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
      return;
    }

    // Within geofence - proceed with marking as complete
    setState(() => _loadingVisitId = directory.id);
    try {
      // Pass current location and directory type to API
      final success = await ref.read(beatPlanDetailViewModelProvider(beatPlanId).notifier).markVisitComplete(
        beatPlanId,
        directory.id,
        directoryType: directory.type,
        userLatitude: _currentLocation!.latitude,
        userLongitude: _currentLocation!.longitude,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ ${directory.name} marked as visited\n'
              'Distance: ${GeofencingService.instance.formatDistance(geofenceResult.distance)}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark visit: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingVisitId = null);
      }
    }
  }

  Future<void> _handleMarkVisitPending(String beatPlanId, String visitId) async {
    setState(() => _loadingVisitId = visitId);
    try {
      final success = await ref.read(beatPlanDetailViewModelProvider(beatPlanId).notifier).markVisitPending(beatPlanId, visitId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Visit marked as pending'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark visit: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingVisitId = null);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in-progress':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48.sp,
              color: AppColors.greyMedium,
            ),
            SizedBox(height: 12.h),
            Text(
              'No directories in this filter',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64.sp,
            color: AppColors.greyMedium,
          ),
          SizedBox(height: 16.h),
          Text(
            'Beat Plan Not Found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading beat plan details...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load beat plan',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(beatPlanDetailViewModelProvider(widget.beatPlanId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
