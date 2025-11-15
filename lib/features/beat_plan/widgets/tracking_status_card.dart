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
  TrackingState _currentState = TrackingState.idle;

  @override
  void initState() {
    super.initState();
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getStateColor(),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStateColor().withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with animated tracking indicator
          Row(
            children: [
              // Pulsing dot indicator
              _buildPulsingIndicator(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStateText(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getStatusDescription(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Connection status icon
              _buildConnectionStatusIcon(),
            ],
          ),

          SizedBox(height: 16.h),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: _formatDuration(_currentStats!.trackingDuration),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.cloud_queue,
                  label: 'Queued',
                  value: '${_currentStats!.queuedLocations}',
                  color: _currentStats!.queuedLocations > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Connection Status Bar
          _buildConnectionStatusBar(),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
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
      statusIcon = Icons.stream;
    } else if (isOnline) {
      statusText = 'Connecting to server...';
      statusColor = AppColors.warning;
      statusIcon = Icons.sync;
    } else {
      statusText = 'Offline - Queueing location updates';
      statusColor = AppColors.error;
      statusIcon = Icons.offline_bolt;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            size: 16.sp,
            color: statusColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (queuedCount > 0 && !isSocketConnected)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$queuedCount pending',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
