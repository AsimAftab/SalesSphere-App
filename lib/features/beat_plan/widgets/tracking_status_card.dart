import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';

/// Tracking Status Card
/// Displays real-time tracking information including:
/// - Connection status (online/offline, socket status)
/// - Queued locations count
/// - Tracking duration
/// - Visual tracking indicator
class TrackingStatusCard extends StatefulWidget {
  const TrackingStatusCard({super.key});

  @override
  State<TrackingStatusCard> createState() => _TrackingStatusCardState();
}

class _TrackingStatusCardState extends State<TrackingStatusCard> {
  TrackingStats? _currentStats;
  late TrackingState _currentState;

  @override
  void initState() {
    super.initState();
    // Initialize with current state from coordinator
    _currentState = TrackingCoordinator.instance.currentState;
    _subscribeToTracking();
  }

  void _subscribeToTracking() {
    // Listen to tracking stats updates
    TrackingCoordinator.instance.onStatsChanged.listen((stats) {
      if (mounted) {
        setState(() {
          _currentStats = stats;
        });
      }
    });

    // Listen to tracking state changes
    TrackingCoordinator.instance.onStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _currentState = state;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStats == null || !_currentStats!.isTracking) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStateColor().withOpacity(0.08),
            _getStateColor().withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _getStateColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStateColor().withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with animated tracking indicator
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                // Animated pulsing indicator
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _getStateColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _buildPulsingIndicator(),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStateText(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getStatusDescription(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Connection status icon
                _buildConnectionStatusIcon(),
              ],
            ),
          ),

          // Stats Section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: _formatDuration(_currentStats!.trackingDuration),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.cloud_queue_outlined,
                        label: 'Queued',
                        value: '${_currentStats!.queuedLocations}',
                        color: _currentStats!.queuedLocations > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Connection Status Bar
                _buildConnectionStatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getStateColor(),
            boxShadow: [
              BoxShadow(
                color: _getStateColor().withOpacity(value),
                blurRadius: 8 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {}); // Trigger rebuild to restart animation
        }
      },
    );
  }

  Widget _buildConnectionStatusIcon() {
    final isOnline = _currentStats?.isOnline ?? false;
    final isSocketConnected = _currentStats?.isSocketConnected ?? false;

    IconData icon;
    Color color;

    if (isSocketConnected) {
      icon = Icons.cloud_done;
      color = AppColors.success;
    } else if (isOnline) {
      icon = Icons.cloud_off;
      color = AppColors.warning;
    } else {
      icon = Icons.signal_wifi_off;
      color = AppColors.error;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        icon,
        size: 20.sp,
        color: color,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusBar() {
    final isOnline = _currentStats?.isOnline ?? false;
    final isSocketConnected = _currentStats?.isSocketConnected ?? false;
    final queuedCount = _currentStats?.queuedLocations ?? 0;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isSocketConnected) {
      statusText = 'Live streaming location updates';
      statusColor = AppColors.success;
      statusIcon = Icons.wifi;
    } else if (isOnline) {
      statusText = 'Connecting to server...';
      statusColor = AppColors.warning;
      statusIcon = Icons.sync;
    } else {
      statusText = 'Offline - Queueing location updates';
      statusColor = AppColors.error;
      statusIcon = Icons.wifi_off;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              statusIcon,
              size: 18.sp,
              color: statusColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (queuedCount > 0 && !isSocketConnected)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '$queuedCount location${queuedCount > 1 ? 's' : ''} pending sync',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Status Indicator
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor() {
    switch (_currentState) {
      case TrackingState.active:
        return AppColors.success;
      case TrackingState.paused:
        return AppColors.warning;
      case TrackingState.starting:
      case TrackingState.stopping:
        return AppColors.primary;
      case TrackingState.error:
        return AppColors.error;
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case TrackingState.active:
        return 'Tracking Active';
      case TrackingState.paused:
        return 'Tracking Paused';
      case TrackingState.starting:
        return 'Starting Tracking...';
      case TrackingState.stopping:
        return 'Stopping Tracking...';
      case TrackingState.error:
        return 'Tracking Error';
      default:
        return 'Tracking Inactive';
    }
  }

  String _getStatusDescription() {
    switch (_currentState) {
      case TrackingState.active:
        return 'Recording your location in real-time';
      case TrackingState.paused:
        return 'Location tracking temporarily paused';
      case TrackingState.starting:
        return 'Initializing GPS and services...';
      case TrackingState.stopping:
        return 'Finalizing tracking session...';
      case TrackingState.error:
        return 'Please check permissions and try again';
      default:
        return 'Location tracking not active';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
