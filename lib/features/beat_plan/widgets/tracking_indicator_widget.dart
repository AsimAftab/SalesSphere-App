import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';

/// Tracking Indicator Widget
/// Displays a compact animated indicator showing tracking status
/// Can be used in app bars or as a floating widget
class TrackingIndicatorWidget extends StatefulWidget {
  final bool showLabel;
  final double size;

  const TrackingIndicatorWidget({
    super.key,
    this.showLabel = true,
    this.size = 12.0,
  });

  @override
  State<TrackingIndicatorWidget> createState() =>
      _TrackingIndicatorWidgetState();
}

class _TrackingIndicatorWidgetState extends State<TrackingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  TrackingState _currentState = TrackingState.idle;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _subscribeToTrackingState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _subscribeToTrackingState() {
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
    if (!TrackingCoordinator.instance.isTracking) {
      return const SizedBox.shrink();
    }

    final color = _getStateColor();
    final label = _getStateLabel();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.showLabel ? 12.w : 8.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing dot
              Container(
                width: widget.size.w,
                height: widget.size.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_animationController.value),
                      blurRadius: 8 * _animationController.value,
                      spreadRadius: 2 * _animationController.value,
                    ),
                  ],
                ),
              ),

              if (widget.showLabel) ...[
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

  String _getStateLabel() {
    switch (_currentState) {
      case TrackingState.active:
        return 'Tracking';
      case TrackingState.paused:
        return 'Paused';
      case TrackingState.starting:
        return 'Starting...';
      case TrackingState.stopping:
        return 'Stopping...';
      case TrackingState.error:
        return 'Error';
      default:
        return 'Inactive';
    }
  }
}

/// Compact version for app bar usage
class CompactTrackingIndicator extends StatelessWidget {
  const CompactTrackingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrackingIndicatorWidget(
      showLabel: false,
      size: 10.0,
    );
  }
}
