import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/core/services/location_permission_service.dart';
import 'package:sales_sphere/core/widgets/location_permission_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    final beatPlansAsync = ref.watch(beatPlanListViewModelProvider);

    return beatPlansAsync.when(
      data: (beatPlans) {
        if (beatPlans.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Beat Plans",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${beatPlans.length} ${beatPlans.length == 1 ? 'plan' : 'plans'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Beat Plan Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: beatPlans.length,
              itemBuilder: (context, index) {
                final beatPlan = beatPlans[index];
                final isPending = beatPlan.status.toLowerCase() == 'pending';
                final isLoading = _loadingBeatPlanId == beatPlan.id;

                return BeatPlanSummaryCard(
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
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Future<void> _handleStartBeatPlan(String beatPlanId) async {
    // Step 1: Check and request location permissions
    AppLogger.i('🔑 Checking location permissions...');

    final permissionResult = await LocationPermissionService.instance
        .requestTrackingPermissions(
      context: context,
      requireBackground: true,
    );

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
          Icon(
            Icons.route_outlined,
            size: 64.sp,
            color: AppColors.greyMedium,
          ),
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
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
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
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading beat plan...',
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
        ],
      ),
    );
  }
}
