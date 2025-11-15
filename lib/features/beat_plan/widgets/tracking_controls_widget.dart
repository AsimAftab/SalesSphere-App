import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Tracking Controls Widget
/// Provides buttons to control tracking:
/// - Pause/Resume tracking
/// - Stop tracking
/// - Visual feedback for current state
class TrackingControlsWidget extends StatefulWidget {
  final VoidCallback? onTrackingStopped;

  const TrackingControlsWidget({
    super.key,
    this.onTrackingStopped,
  });

  @override
  State<TrackingControlsWidget> createState() => _TrackingControlsWidgetState();
}

class _TrackingControlsWidgetState extends State<TrackingControlsWidget> {
  TrackingState _currentState = TrackingState.idle;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _subscribeToTrackingState();
  }

  void _subscribeToTrackingState() {
    TrackingCoordinator.instance.onStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _currentState = state;
          if (state == TrackingState.active ||
              state == TrackingState.paused ||
              state == TrackingState.idle ||
              state == TrackingState.stopped) {
            _isProcessing = false;
          }
        });
      }
    });
  }

  Future<void> _handlePauseResume() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (_currentState == TrackingState.active) {
        AppLogger.i('⏸️ Pausing tracking...');
        await TrackingCoordinator.instance.pauseTracking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking paused'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (_currentState == TrackingState.paused) {
        AppLogger.i('▶️ Resuming tracking...');
        await TrackingCoordinator.instance.resumeTracking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking resumed'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.e('❌ Error toggling tracking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle tracking: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleStop() async {
    if (_isProcessing) return;

    // Show confirmation dialog
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Tracking?'),
        content: const Text(
          'Are you sure you want to stop tracking? This will end your current beat plan session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (shouldStop != true) return;

    setState(() => _isProcessing = true);

    try {
      AppLogger.i('🛑 Stopping tracking...');
      await TrackingCoordinator.instance.stopTracking();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking stopped successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        // Notify parent widget
        widget.onTrackingStopped?.call();
      }
    } catch (e) {
      AppLogger.e('❌ Error stopping tracking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop tracking: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!TrackingCoordinator.instance.isTracking) {
      return const SizedBox.shrink();
    }

    final isPaused = _currentState == TrackingState.paused;
    final isActive = _currentState == TrackingState.active;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pause/Resume Button
          Expanded(
            child: _ControlButton(
              icon: isPaused ? Icons.play_arrow : Icons.pause,
              label: isPaused ? 'Resume' : 'Pause',
              color: isPaused ? AppColors.success : AppColors.warning,
              onPressed: (isActive || isPaused) && !_isProcessing
                  ? _handlePauseResume
                  : null,
              isLoading: _isProcessing &&
                  (_currentState == TrackingState.starting ||
                      _currentState == TrackingState.stopping),
            ),
          ),

          SizedBox(width: 12.w),

          // Stop Button
          Expanded(
            child: _ControlButton(
              icon: Icons.stop,
              label: 'Stop',
              color: AppColors.error,
              onPressed: (isActive || isPaused) && !_isProcessing
                  ? _handleStop
                  : null,
              isLoading: _isProcessing && _currentState == TrackingState.stopping,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.3),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
