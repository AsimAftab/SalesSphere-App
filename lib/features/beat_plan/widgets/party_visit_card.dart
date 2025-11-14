import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';

/// Party Visit Card
/// Displays individual party visit information with action buttons
class PartyVisitCard extends StatelessWidget {
  final BeatDirectory party;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onMarkPending;
  final bool isLoading;

  const PartyVisitCard({
    super.key,
    required this.party,
    this.onMarkComplete,
    this.onMarkPending,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isVisited = party.visitStatus.status.toLowerCase() == 'visited';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isVisited
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isVisited ? AppColors.success : AppColors.secondary).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            // Colored top stripe
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: isVisited ? AppColors.success : AppColors.secondary,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Party name and owner
                  Row(
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: (isVisited ? AppColors.success : AppColors.secondary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          isVisited ? Icons.store_rounded : Icons.storefront_outlined,
                          size: 22.sp,
                          color: isVisited ? AppColors.success : AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              party.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    party.ownerName,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isVisited
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVisited ? Icons.check_circle : Icons.schedule,
                              size: 14.sp,
                              color: isVisited ? AppColors.success : AppColors.secondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isVisited ? 'Visited' : 'Pending',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isVisited ? AppColors.success : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Address section
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            party.location.address,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Action button
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : isVisited
                            ? onMarkPending
                            : onMarkComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVisited ? AppColors.warning : AppColors.success,
                      disabledBackgroundColor: AppColors.neutral.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.shadow,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isVisited ? Icons.refresh_rounded : Icons.check_circle_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                isVisited ? 'Mark as Pending' : 'Mark as Completed',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
