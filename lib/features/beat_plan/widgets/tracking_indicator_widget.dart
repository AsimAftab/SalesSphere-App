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
  late TrackingState _currentState;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize with current state from coordinator
    _currentState = TrackingCoordinator.instance.currentState;

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
            horizontal: widget.showLabel ? 14.w : 10.w,
            vertical: widget.showLabel ? 8.h : 6.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing dot with enhanced animation
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  Container(
                    width: (widget.size * 2).w,
                    height: (widget.size * 2).w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha:_animationController.value * 0.2),
                    ),
                  ),
                  // Inner dot
                  Container(
                    width: widget.size.w,
                    height: widget.size.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha:_animationController.value * 0.6),
                          blurRadius: 8 * _animationController.value,
                          spreadRadius: 2 * _animationController.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (widget.showLabel) ...[
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.3,
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
