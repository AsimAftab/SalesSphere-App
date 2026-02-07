import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/location_permission_service.dart';
import 'package:sales_sphere/core/services/tracking_coordinator.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/core/widgets/location_permission_dialog.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';
import 'package:sales_sphere/features/beat_plan/vm/beat_plan.vm.dart';
import 'package:sales_sphere/features/beat_plan/widgets/beat_plan_summary_card.dart';

/// Beat Plan Section for Home Screen
/// Displays beat plan summaries as cards
class BeatPlanSection extends ConsumerStatefulWidget {
  const BeatPlanSection({super.key});

  @override
  ConsumerState<BeatPlanSection> createState() => _BeatPlanSectionState();
}

class _BeatPlanSectionState extends ConsumerState<BeatPlanSection> {
  String? _loadingBeatPlanId;
  bool _isRefreshing = false;
  int _selectedTabIndex = 0;

  // Tab options
  static const List<String> _tabTitles = ['Active & Pending', 'Completed'];

  // Track tracking state locally to avoid all cards rebuilding
  TrackingState? _lastTrackingState;

  @override
  void initState() {
    super.initState();
    // Listen to tracking state changes but only rebuild when relevant
    TrackingCoordinator.instance.onStateChanged.listen((state) {
      // Only rebuild if state actually changed (avoid unnecessary rebuilds)
      if (mounted && state != _lastTrackingState) {
        _lastTrackingState = state;
        setState(() {});
      }
    });
  }

  /// Handles refresh for beat plans
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(beatPlanListViewModelProvider.notifier).refresh();
    } catch (e) {
      AppLogger.e('Error refreshing beat plans: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final beatPlansAsync = ref.watch(beatPlanListViewModelProvider);

    return beatPlansAsync.when(
      data: (beatPlans) {
        if (beatPlans.isEmpty) {
          return _buildEmptyState();
        }

        // Filter beat plans based on selected tab
        final filteredPlans = _getFilteredPlans(beatPlans, _selectedTabIndex);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "My Beat Plans",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${beatPlans.length} ${beatPlans.length == 1 ? 'plan' : 'plans'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Refresh button
                    IconButton(
                      onPressed: _isRefreshing ? null : _handleRefresh,
                      padding: EdgeInsets.all(4.r),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.w,
                      ),
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              Icons.refresh_outlined,
                              size: 20.sp,
                              color: AppColors.primary,
                            ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Tab Bar - using custom widget instead of TabBar
            Container(
              decoration: BoxDecoration(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(4.r),
              child: Row(
                children: List.generate(_tabTitles.length, (index) {
                  final isSelected = _selectedTabIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.all(4.r),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.cardBackground
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.shadow.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _tabTitles[index],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 16.h),

            // Content - simple ListView instead of TabBarView
            Expanded(
              child: filteredPlans.isEmpty
                  ? _buildTabEmptyState(_getEmptyMessage(_selectedTabIndex))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredPlans.length,
                      itemBuilder: (context, index) {
                        final beatPlan = filteredPlans[index];
                        final isPending =
                            beatPlan.status.toLowerCase() == 'pending';
                        final isLoading = _loadingBeatPlanId == beatPlan.id;

                        return BeatPlanSummaryCard(
                          key: ValueKey('beat-plan-${beatPlan.id}'),
                          beatPlan: beatPlan,
                          onTap: () {
                            context.pushNamed(
                              'beat-plan-details',
                              pathParameters: {'beatPlanId': beatPlan.id},
                            );
                          },
                          // Only show Start button for pending beat plans
                          onStartBeatPlan: isPending
                              ? () => _handleStartBeatPlan(beatPlan.id)
                              : null,
                          isLoadingStart: isLoading,
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  /// Get filtered plans based on selected tab index
  List<BeatPlanSummary> _getFilteredPlans(
    List<BeatPlanSummary> allBeatPlans,
    int tabIndex,
  ) {
    if (tabIndex == 0) {
      // Active & Pending tab
      final filtered = allBeatPlans.where((plan) {
        final status = plan.status.toLowerCase();
        return status == 'active' ||
            status == 'in-progress' ||
            status == 'pending';
      }).toList();

      // Sort: active/in-progress first, then pending
      filtered.sort((a, b) {
        final statusA = a.status.toLowerCase();
        final statusB = b.status.toLowerCase();

        // Priority: active/in-progress > pending
        final priorityA = (statusA == 'active' || statusA == 'in-progress')
            ? 0
            : 1;
        final priorityB = (statusB == 'active' || statusB == 'in-progress')
            ? 0
            : 1;

        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }

        // Within same priority, sort by assigned date (newest first)
        try {
          final dateA = DateTime.parse(a.assignedDate);
          final dateB = DateTime.parse(b.assignedDate);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

      return filtered;
    } else {
      // Completed tab
      final filtered = allBeatPlans.where((plan) {
        return plan.status.toLowerCase() == 'completed';
      }).toList();

      // Sort: by completed date (newest first), then assigned date
      filtered.sort((a, b) {
        try {
          // Try to sort by completed date first
          if (a.completedAt != null && b.completedAt != null) {
            final dateA = DateTime.parse(a.completedAt!);
            final dateB = DateTime.parse(b.completedAt!);
            return dateB.compareTo(dateA);
          }
        } catch (_) {}

        // Fallback to assigned date
        try {
          final dateA = DateTime.parse(a.assignedDate);
          final dateB = DateTime.parse(b.assignedDate);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

      return filtered;
    }
  }

  /// Get empty message based on selected tab
  String _getEmptyMessage(int tabIndex) {
    return tabIndex == 0
        ? 'No active or pending beat plans'
        : 'No completed beat plans yet';
  }

  /// Builds empty state for a tab
  Widget _buildTabEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48.sp,
            color: AppColors.greyMedium,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartBeatPlan(String beatPlanId) async {
    // Step 1: Check and request location permissions
    AppLogger.i('🔑 Checking location permissions...');

    final permissionResult = await LocationPermissionService.instance
        .requestTrackingPermissions(context: context, requireBackground: true);

    if (!permissionResult.success) {
      AppLogger.w('⚠️ Location permission denied');

      if (mounted) {
        // Show permission dialog
        final requestedAgain = await LocationPermissionDialog.show(
          context,
          requireBackground: true,
        );

        if (requestedAgain != true) {
          // User cancelled or denied
          SnackbarUtils.showWarning(
            context,
            'Location permission is required for tracking',
          );
          return;
        }

        // Check permission again after dialog
        final retryResult = await LocationPermissionService.instance
            .requestTrackingPermissions(
              context: context,
              requireBackground: true,
            );

        if (!retryResult.success) {
          SnackbarUtils.showError(
            context,
            'Location permission is required for tracking',
          );
          return;
        }
      } else {
        return;
      }
    }

    AppLogger.i('✅ Location permissions granted');

    // Step 2: Start beat plan (this will also start tracking)
    setState(() => _loadingBeatPlanId = beatPlanId);

    try {
      final success = await ref
          .read(beatPlanListViewModelProvider.notifier)
          .startBeatPlan(beatPlanId);

      if (success && mounted) {
        // Show success message
        SnackbarUtils.showSuccess(
          context,
          'Beat plan started successfully! Tracking is now active.',
        );

        // Navigate to beat plan details
        context.pushNamed(
          'beat-plan-details',
          pathParameters: {'beatPlanId': beatPlanId},
        );
      }
    } catch (e) {
      AppLogger.e('Error starting beat plan: $e');
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to start beat plan: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingBeatPlanId = null);
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined, size: 64.sp, color: AppColors.greyMedium),
          SizedBox(height: 16.h),
          Text(
            'No Beat Plan Assigned',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Contact your manager to get assigned',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
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
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Loading beat plan...',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
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
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
