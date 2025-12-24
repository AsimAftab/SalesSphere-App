import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/beat_plan/widgets/beat_plan_section.dart';





class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Define your SVG asset path
  // (Removed static path, as it's directly in the SvgPicture.asset)

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);


    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // Header Section
            _buildHeader(user),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const BeatPlanSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) { // Assuming 'user' can be null
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h), // Adjusted padding
      child: Row(
        children: [
          // Greeting and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // --- USE THE NEW _getFirstName FUNCTION ---
                            _getFirstName(user?.name),
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: AppColors.textOrange,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          // --- REPLACED CONTAINER WITH SVG ---
                          SvgPicture.asset(
                            'assets/images/dashboard_arc.svg',
                            width: 80.w, // Adjust as needed
                            height: 8.h,  // Adjust as needed
                            colorFilter: const ColorFilter.mode(AppColors.textOrange, BlendMode.srcIn), // Color the SVG
                          ),
                          // -----------------------------------
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // --- RE-ADDED MISSING PADDING WIDGET ---
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.h),
                      child: Text(
                        '👋',
                        style: TextStyle(fontSize: 28.sp),
                      ),
                    ),
                    // ----------------------------------------
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Notification Bell
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.notifications_outlined,
              size: 24.sp,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(width: 12.w),

          // Settings Icon
          GestureDetector(
            onTap: () => context.pushNamed('settings'),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.settings_outlined,
                size: 24.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // User Avatar (Your code for this was perfect)
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
    );
  }

  /// Get first name from full name
  String _getFirstName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'User'; // Fallback
    }
    // Split by space and take the first part
    final parts = name.trim().split(' ');
    if (parts.isNotEmpty) {
      return parts[0]; // Return the first part (e.g., "Bikram")
    }
    return 'User'; // Fallback
  }

  /// Get initials from name for avatar fallback
  String _getInitials(String name) {
    // --- NEW LOGIC ---
    // Get the trimmed name, and if it's not empty,
    // take the very first character.
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName[0].toUpperCase();
    }
    // -----------------
    return 'U'; // Fallback
  }
}

