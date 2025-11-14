import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/beat_plan/vm/beat_plan.vm.dart';
import 'package:sales_sphere/features/beat_plan/widgets/beat_plan_summary_card.dart';

/// Beat Plan Section for Home Screen
/// Displays beat plan summaries as cards
class BeatPlanSection extends ConsumerWidget {
  const BeatPlanSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                return BeatPlanSummaryCard(
                  beatPlan: beatPlan,
                  onTap: () {
                    context.pushNamed(
                      'beat-plan-details',
                      pathParameters: {'beatPlanId': beatPlan.id},
                    );
                  },
                  onStartBeatPlan: () {
                    // Navigate to beat plan details screen when Start button is clicked
                    context.pushNamed(
                      'beat-plan-details',
                      pathParameters: {'beatPlanId': beatPlan.id},
                    );
                  },
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
