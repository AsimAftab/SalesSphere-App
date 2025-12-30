import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/widget/utility_card.dart';

class UtilitiesScreen extends ConsumerWidget {
  const UtilitiesScreen({super.key});

  String _getInitials(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilities',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Access additional field tools and actions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed('profile'),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textOrange,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26.r,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                _getInitials(user?.name ?? 'User'),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.99,
                children: const [
                  UtilityCard(
                    title: 'Odometer',
                    subtitle: 'Track travel distance during field visits',
                    icon: Icons.speed_rounded,
                    iconColor: Color(0xFF448AFF),
                    routePath: '/odometer',
                  ),
                  UtilityCard(
                    title: 'Expense Claims',
                    subtitle: 'Submit and manage expense claims',
                    icon: Icons.currency_rupee_rounded,
                    iconColor: Color(0xFF00C853),
                    routePath: '/expense-claims',
                  ),
                  UtilityCard(
                    title: 'Notes & Complaints',
                    subtitle: 'Log discussions, feedback & issues',
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Color(0xFFFF5252),
                    routePath: '/notes-complaints',
                  ),
                  UtilityCard(
                    title: 'Miscellaneous Work',
                    subtitle: 'Log unplanned field tasks and assignments',
                    icon: Icons.work_outline_rounded,
                    iconColor: Color(0xFF7C4DFF),
                    routePath: '/miscellaneous-work',
                  ),
                  UtilityCard(
                    title: 'Tour Plan',
                    subtitle: 'Plan and manage daily field visits',
                    icon: Icons.navigation_outlined,
                    iconColor: Color(0xFFFF9100),
                    routePath: '/tour-plan',
                  ),
                  UtilityCard(
                    title: 'Attendance',
                    subtitle: 'Mark and track daily attendance',
                    icon: Icons.calendar_month_rounded,
                    iconColor: Color(0xFF00ACC1),
                    routePath: '/attendance',
                  ),
                ],
              ),

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}